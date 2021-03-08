---
title: Redis-两次redis操作用不用pipeline
comments: true
date: 2021-03-07 19:31:08
author:
tags:
 - Redis
categories:
 - 中间件
---

#### 为什么需要 pipeline ？
- 正常情况下，客户端发送一个命令，等待 Redis 应答；Redis 接收到命令，处理后应答。请求发出到响应的时间叫做往返时间，即 RTT（Round Time Trip）。在这种情况下，如果需要执行大量的命令，就需要等待上一条命令应答后再执行。这中间不仅仅多了许多次 RTT，而且还频繁的调用系统 IO，发送网络请求。
- pipeline 允许客户端可以一次发送多条命令，而不等待上一条命令执行的结果。
![在这里插入图片描述](https://imgconvert.csdnimg.cn/aHR0cHM6Ly9zZWdtZW50ZmF1bHQuY29tL2ltZy9iVlY5MTY?x-oss-process=image/format,png)
#### 两次redis操作，用pipeline会不会好一点
- 执行10万次set
```python
import redis
import time

if __name__ == '__main__':
    my_redis = redis.StrictRedis(connection_pool=redis.ConnectionPool.from_url("redis://:@127.0.0.1/0"), socket_timeout=2)
	# 不用pipeline
    start_time = int(time.time() * 1000)
    for i in range(0,100000):
        key1 = "test1_%s" % i
        my_redis.set(key1, i)
        my_redis.expire(key1, 3600)
    end_time = int(time.time() * 1000)
    print end_time - start_time

	# 使用pipeline
    start_time = int(time.time() * 1000)
    pipe = my_redis.pipeline()
    for i in range(0,100000):
        key1 = "test2_%s" % i
        pipe.set(key1, i)
        pipe.expire(key1, 3600)
    pipe.execute()
    end_time = int(time.time() * 1000)
    print end_time - start_time
```
- 执行结果
> 16651、14477、15041 # 不用pipeline
> 4517、4158、4325  # 使用pipeline
- 初步结论
> 即使只有两次redis操作，pipeline的效果也很突出。

#### 两次已经表现优异了，次数多点怎么样？
- 执行100万次sadd 操作
```python
    start_time = int(time.time() * 1000)
    for i in range(0, 100000):
        for j in range(0, 10):
            key1 = "test1_%s_%s" % (i,j)
            my_redis.sadd(key1, i)
        my_redis.expire(key1, 3600)
    end_time = int(time.time() * 1000)
    print end_time - start_time

    start_time = int(time.time() * 1000)
    pipe = my_redis.pipeline()
    for i in range(0, 100000):
        for j in range(0,10):
            key1 = "test2_%s_%s" % (i,j)
            pipe.sadd(key1, i)
        pipe.expire(key1, 3600)
    pipe.execute()
    end_time = int(time.time() * 1000)
    print end_time - start_time
```

- 执行结果
> 83849
> 26313
- 初步结论
> pipeline居家必备
