---
title: Mysql-InnoDB存储引擎
comments: true
date: 2021-03-07 18:31:06
author:
tags:
 - Mysql
categories:
 - 数据库
---

### InnoDB引擎的4大特性
1. 插入缓存（物理页的一个组成部分）

   ```mysql
   show engine innodb status\G;
   INSERT BUFFER AND ADAPTIVE HASH INDEX # 插入缓冲信息
   ```

   对于非聚集索引的插入或更新操作，不是每次直接插入索引页。而是先判断插入的非聚集索引页是否在缓冲池中。如果在，则直接插入，如果不在，先放入插入缓冲区，然后再以一定的频率执行插入缓冲和非聚集索引页子节点的合并操作。

   > 那什么时候进行合并呢？
   >
   > - 非聚集索引页被读取到缓冲池中。select先检查insert buffer是否有非聚集索引页的存在，如果有则合并。
   > - 非聚集索引页没有可用空间。空间小于1/32页的大小，则进行合并。
   > - master thread每秒和每10秒的合并操作。

   这样通常能将多个插入合并到一个操作中，目的还是为了减少随机IO带来性能损耗。

   使用需要满足两个条件

   - 索引是非聚集索引
   - 索引不是唯一索引的

2. 两次写 double write

   二次写缓存位于系统表空间，用来缓存从buffer poll中flush之后，写入数据文件之前的数据。数据页到double write以一次大的连续块的方式写入，需要的IO消耗小于写入数据文件的消耗。

   > double write的组成：
   >
   > - 内存中double write buffer，大小为2M。
   >
   > - 物理磁盘上共享表空间中连续的128个页，即两个区，大小为2M。

   对缓冲池中的脏页进行刷新时，不是直接写磁盘，而是将脏页先复制到内存中的double write buffer，之后通过double write分两次，每次1M顺序的写入共享表空间的物理磁盘上。因为double write页是连续的，顺序写的开销很小。在完成double write页的写入后，再将double write buffer 中的页写入各个表空间文件中。这时的写入是离散的，如果在写入过程中出现崩溃，可以使用共享表空间的double write页进行恢复。

3. 自适应哈希索引

   InnoDB会监控对表上索引的查找，如果建立哈希索引可以带来速度的提升，则建立哈希索引。自适应哈希索引通过缓冲池的B+树构造，因此建立速度很快。

   哈希索引会根据访问的频率和模式为==某些页建==立哈希索引，而不是整个表。

   自适应哈希索引占用InnoDB buffer poll的空间。

4. 预读

   - 随机预读（已废弃）

     当一个区中==13==个页在缓冲区中，并在LRU列表的前端，则InnoDB存储引擎会将这个区中剩余的所有页都预读到缓冲区。InnoDB Plugin 1.0.4开始，随机预读被取消。

   - 线性预读

     基于缓冲池中页的访问模式，而不是数量。如果一个区中的N个页都被顺序的访问了，则InnoDB会读取下一个区的所有页。N的值由`innodb_read_ahead_threshold`控制，默认值56。




### InnoDB体系架构
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200504133348713.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpeXV4aW5nNjYzOTgwMQ==,size_16,color_FFFFFF,t_70#pic_center)


#### 后台线程

默认情况下InnoDB后台有7个线程（版本不同，线程数可能不同；线程数也可以配置）

1. 1个master thread（几乎实现了所有功能）

2. 1个锁监控线程

3. 1个错误监控线程

4. 4个I/O thread（不同版本read write线程数可能不同）

   > Insert  buffer thread
   >
   > Log thread
   >
   > Read thread
   >
   > Write  thread
   >
   > ```mysql
   > show engine innodb status\G; # 过去某个时间段的数据库状态
   > 
   > Per second averages calculated from the last 46 seconds # 过去46s内的状态
   > 
   > FILE I/O
   > xxx
   > ```

#### 内存

1. 缓冲池 buffer poll

   占最大块内存，InnoDB将数据库文件按页（16k）读到缓冲池，然后按LRU保留缓存数据。数据库文件需要修改，首先修改缓冲池中的页（发生修改后，该页为脏页），按照一定的频率将缓冲池中的脏页刷新到文件。

   ```mysql
   show engine innodb status\G;
   
   BUFFER POOL AND MEMORY
   Buffer pool size   8191 # 一共多少个缓冲帧
   Free buffers       7529 # 空闲缓冲帧
   Database pages     658 # 已经使用缓冲帧
   Old database pages 262
   Modified db pages  0 # 脏页数量
   ```

   - 缓冲池中的数据页类型
     1. 索引页
     2. 数据页
     3. undo页
     4. 插入缓冲 insert buffer
     5. 自适应hash索引
     6. InnoDB锁信息 lock info
     7. 数据字典信息 data dictionary

2. 重做日志缓冲池 redo log buffer

3. 额外内存池 additional memory poll