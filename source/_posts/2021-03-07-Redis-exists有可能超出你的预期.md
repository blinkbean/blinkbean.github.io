---
title: Redis-exists有可能超出你的预期
comments: true
date: 2021-03-07 19:40:58
author:
tags:
 - Redis
categories:
 - 后端开发
---

#### Redis的Exists有可能超出你的预期
- 理论上每个key都应该有过期时间（当然也可以是一万年），通常情况下用exists来判断一个key是否存在都没什么问题（一般过期时间都比较长）。但如果过期时间需要精确到秒或十秒及，那么exists就会出乎你的意料。

#### Redis过期键删除策略
- Redis key过期的方式有三种：
1. 被动删除：当读/写一个已经过期的key时，会触发惰性删除策略，直接删除掉这个过期key
> 对这个key执行exists不会触发惰性删除
2. 主动删除：由于惰性删除策略无法保证冷数据被及时删掉，所以Redis会定期主动淘汰一批已过期的key
3. 当前已用内存超过maxmemory限定时，触发主动清理策略
```py
    def get_chatroom_user_tips(self, uid):
        if not self.chatroom_redis.exists("flag_key"):
            value = self.redis.get("key", 0 , 0)
            # 间隔时间
            _interval = 30
            if group_ids:
                self.redis.setex("flag_key", value=1, time=_interval)
                self.redis.delete("key")
            return group_ids
```
###### 上面代码存在的问题及应对方式
问题
- redis Key在30s之后过期，但是执行exists命令的返回值可能还为True。
- 但是如果执行ttl命令是发现返回值为0。


解决

- 用ttl代替exists

```py
    def get_chatroom_user_tips(self, uid):
        if self.chatroom_redis.ttl("flag_key") <= 0:
            value = self.redis.get("key", 0 , 0)
            # 间隔时间
            _interval = 30
            if group_ids:
                self.redis.setex("flag_key", value=1, time=_interval)
                self.redis.delete("key")
            return group_ids
```