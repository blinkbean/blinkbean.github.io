---
title: Golang sync/atomic包的原子操作是怎么保证的
date: 2021-03-07 17:28:35
author: 
tags: 
 - Golang
 - atomic包
categories: 
 - 后端开发
---
在Go语言标准库中，`sync/atomic`包将底层硬件提供的原子级内存操作封装成了Go的函数。

`Mutex`由操作系统实现，而atomic包中的原子操作则由底层硬件直接提供支持。在CPU实现的指令集里，有一些指令直接封装进atomic包，这些指令在执行过程中是不允许中断的，因此原子操作可以在`lock-free`的情况下保证并发安全，并且它的性能也能做到随CPU个数的增多而线性扩展。

### 数据类型

- int32
- int64
- uint32
- uint64
- uintptr
- unsafe.Pointer

### 操作类型

- 增或减 AddXXX

  ```go
  *addr += delta
  return *addr
  ```

- 比较并交换 CompareAndSwapXXX

  ```go
  if *addr == old {
  	*addr = new
  	return true
  }
  return false
  ```

- 载入 LoadXXX

  ```go
  return *addr
  ```

- 存储 StoreXXX

  ```go
  *addr = val
  ```

- 交换 SwapXXX

  ```go
  old = *addr
  *addr = new
  return old
  ```



### 什么操作叫做原子操作？

一个或者多个操作在CPU执行过程中不被中断的特性，称为原子性(atomicity)。这些操作对外表现成一个不可分割的整体，他们要么都执行，要么都不执行，外界不会看到他们只执行到一半的状态。而在现实世界中，CPU不可能不中断的执行一系列操作，但如果我们在执行多个操作时，能让他们的中间状态对外不可见，那我们就可以宣城他们拥有了“不可分割”的原子性。

在Go中，一条普通的赋值语句其实不是一个原子操作。列如，在32位机器上写int64类型的变量就会有中间状态，因为他会被拆成两次写操作(MOV)——写低32位和写高32位。

### 用锁行不行？
原子操作由**底层硬件**支持，而锁则由操作系统的**调度器**实现。锁应当用来保护一段逻辑，对于一个变量更新的保护，原子操作通常会更有效率，并且更能利用计算机多核的优势，如果要更新的是一个复合对象，则应当使用`atomic.Value`封装好的实现。

#### 值类型操作

- 如果一个线程刚写完低32位，还没来得及写高32位时，另一个线程读取了这个变量，那得到的就是一个毫无逻辑的中间变量，会导致程序出现诡异的bug。

```go
//在被操作值被频繁变更的情况下,CAS操作并不那么容易成功
//利用for循环以进行多次尝试
var value int32

func addValue1(delta int32){
	for{
		//在进行读取value的操作的过程中,其他对此值的读写操作是可以被同时进行的
		//那么这个读操作很可能会读取到一个只被修改了一半的数据
		v := value
		if atomic.CompareAndSwapInt32(&value, v, v + delta){
			break
		}
	}
}
```

- 用Load函数防止只读取一半有效数据的发生

```go
func addValue2(delta int32){
    for{
    	//使用载入
		v := atomic.LoadInt32(&value)
        if atomic.CompareAndSwapInt32(&value, v, v + delta){
            //在函数的结果值为true时,退出循环
            break
        }
    }
}
```

#### struct类型操作

- 如果对一个结构体直接进行赋值，那出现问题的概率更高。线程刚写完一部分字段，读线程就读取了变量，那么只能读到一部分修改的值，破坏了变量的完整性，读到的值也是完全错误的。
- 面对这种多线程下变量的读写问题，1.4 版本的时候 `atomic.Value`登场，它使得我们可以不依赖于不保证兼容性的`unsafe.Pointer`类型，同时又能将任意数据类型的读写操作封装成原子性操作（让中间状态对外不可见）。

```go
// 使用示例

type Config struct {
	Addr string
	Port string
}

func (c Config) String() string {
	return c.Addr + ":" + c.Port
}

func loadConfig() Config {
	// do something
	return Config{}
}
func automicValue() {
	var config atomic.Value
	wg := sync.WaitGroup{}
	go func() {
		for {
			time.Sleep(time.Millisecond)
			config.Store(loadConfig())
		}
	}()

	for i := 0; i < 1000; i++ {
		wg.Add(1)
		go func() {
			c := config.Load().(Config)
			fmt.Println(c)
			wg.Done()
		}()
	}
	wg.Wait()
}
```

#### atomic.Value 设计与实现

`atomic`包中除了`atomic.Value`外，其余都是早期由汇编写成的，`atomic.Value`类型的底层实现也是建立在已有的`atomic`包的基础上。

> ##### goroutine抢占
>
> Go中调度器是GMP模型，简单理解G就是goroutine；M可以类比内核线程，是执行G的地方；P是调度G以及为G的执行准备所需资源。一般情况下，P的数量CPU的可用核心数，也可由`runtime.GOMAXPROCS`指定。
>
> 调度规则：某个G不能一直占用M，在某个时刻的时候，runtime会判断当前M是否可以被抢占，即M上正在执行的G让出。P在合理的时刻将G调度到合理的M上执行，在runtime里面，每个P维护一个本地存放待执行G的队列localq，同时还存在一个全局的待执行G的队列globalq；调度就是P从localq或globalq中取出G到对应的M上执行，所谓抢占，runtime将G抢占移出运行状态，拷贝G的执行栈放入待执行队列中，可能是某个P的localq，也可能是globalq，等待下一次调度，因此当被抢占的G重回待执行队列时有可能此时的P与前一次运行的P并非同一个。
>
> 所谓禁止抢占，即当前执行G不允许被抢占调度，直到禁止抢占标记解除。Go runtime实现了G的禁止抢占与解除禁止抢占。

```go
//atomic.Value源码

type Value struct {
	v interface{} // 所以可以存储任何类型的数据
}

// 空 interface{} 的内部表示格式，作用是将interface{}类型分解，得到其中两个字段
type ifaceWords struct {
	typ  unsafe.Pointer
	data unsafe.Pointer
}

// 取数据就是正常走流程
func (v *Value) Load() (x interface{}) {
	vp := (*ifaceWords)(unsafe.Pointer(v))
	typ := LoadPointer(&vp.typ)
	if typ == nil || uintptr(typ) == ^uintptr(0) {
		// 第一次还没写入
		return nil
	}
  // 构造新的interface{}返回出去
	data := LoadPointer(&vp.data)
	xp := (*ifaceWords)(unsafe.Pointer(&x))
	xp.typ = typ
	xp.data = data
	return
}

// 写数据（如何保证数据完整性）
func (v *Value) Store(x interface{}) {
	if x == nil {
		panic("sync/atomic: store of nil value into Value")
	}
  // 绕过 Go 语言类型系统的检查，与任意的指针类型互相转换
	vp := (*ifaceWords)(unsafe.Pointer(v)) // 旧值
	xp := (*ifaceWords)(unsafe.Pointer(&x)) // 新值
	for { // 配合CompareAndSwap达到乐观锁的功效
		typ := LoadPointer(&vp.typ)
		if typ == nil { // 第一次写入
			runtime_procPin() // 禁止抢占
			if !CompareAndSwapPointer(&vp.typ, nil, unsafe.Pointer(^uintptr(0))) {
				runtime_procUnpin() // 没有抢到锁，说明已经有别的线程抢先完成赋值，重新进入循环
				continue
			}
			// 首次赋值
			StorePointer(&vp.data, xp.data)
			StorePointer(&vp.typ, xp.typ)
			runtime_procUnpin() // 写入成功，解除占用状态
			return
		}
		if uintptr(typ) == ^uintptr(0) {
			// 第一次写入还未完成，继续等待
			continue
		}
		// 两次需要写入相同类型
		if typ != xp.typ {
			panic("sync/atomic: store of inconsistently typed value into Value")
		}
		StorePointer(&vp.data, xp.data)
		return
	}
}

// 禁止抢占，标记当前G在M上不会被抢占，并返回当前所在P的ID。
func runtime_procPin()
// 解除G的禁止抢占状态，之后G可被抢占。
func runtime_procUnpin()

```

---

#### 参考文章

[Go语言中文网](https://studygolang.com/pkgdoc)

[Go 语言标准库中 atomic.Value 的前世今生](https://blog.betacat.io/post/golang-atomic-value-exploration/)

[你不知道的Go unsafe.Pointer uintptr原理和玩法](https://www.cnblogs.com/sunsky303/p/11820500.html)

[理解Go 1.13中sync.Pool的设计与实现](https://segmentfault.com/a/1190000021944703)

[Go Slice 最大容量大小是怎么来的](https://segmentfault.com/a/1190000017783070)

[Golang 的 协程调度机制 与 GOMAXPROCS 性能调优](https://juejin.cn/post/6844903662553137165)

[Golang同步：原子操作使用](https://www.kancloud.cn/digest/batu-go/153537)