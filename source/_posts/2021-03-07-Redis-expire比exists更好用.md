---
title: Redis-expire比exists更好用
comments: true
date: 2021-03-07 19:32:41
author:
tags:
 - Redis
categories:
 - 中间件
---

[参考文章——简书](https://www.jianshu.com/p/9352d20fb2e0)
#### 什么情况下expire比exists更好？
###### 前提
- redis key过期时间必须设置（特殊需求除外），但是如果DB的值有变动会主动更新到redis，所以不会有数据不同步的情况。
###### 场景
- 每次都需要判断某个key是否存在，然后才能执行相应的操作。
###### 问题
- 最坏情况下，代码在执行exists时key是有效的，后面对key进行操作时，发现在那两行代码执行的中间，key被清掉了。
- 条件虽然比较极端，但是在代码里——一切皆有可能。
###### 解决
- expire代替exists，重置key的过期时间。相当于利用expire给key续命，可以合理的“长生不死”。


# 过期相关补充
#### 设置过期时间

```python
    EXPIRE <KEY> <TTL> : 将键的生存时间设为 ttl 秒
    PEXPIRE <KEY> <TTL> :将键的生存时间设为 ttl 毫秒
    EXPIREAT <KEY> <timestamp> :将键的过期时间设为 timestamp 所指定的秒数时间戳
    PEXPIREAT <KEY> <timestamp>: 将键的过期时间设为 timestamp 所指定的毫秒数时间戳.
```

#### 移除过期时间

```python
	persist key
```

#### redis值和过期时间的存储
![在这里插入图片描述](https://imgconvert.csdnimg.cn/aHR0cHM6Ly91cGxvYWQtaW1hZ2VzLmppYW5zaHUuaW8vdXBsb2FkX2ltYWdlcy83MzYxMzgzLTcwMDYyYTM2ZDQxOWZjMTcucG5n?x-oss-process=image/format,png)
#### 删除book键的过期时间后的存储结构
- book键的过期时间没有了
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190823213116792.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpeXV4aW5nNjYzOTgwMQ==,size_16,color_FFFFFF,t_70)