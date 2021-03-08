---
title: Python-BloomFilter实现
comments: true
date: 2021-03-07 19:23:29
author:
tags:
 - Python
 - Redis
categories: ["后端开发"]
---

- 学习笔记，如有不足之处，欢迎指正。

#### 类定义
```python
import math
import time
import redis
from hashlib import md5


class SimpleHash(object):
    def __init__(self, cap, seed):
        self.cap = cap
        self.seed = seed

    def hash(self, value):
        ret = 0
        for i in range(len(value)):
            ret += self.seed * ret + ord(value[i])
        return (self.cap - 1) & ret


class BloomFilter(object):
    # 随机种子
    SEEDS = [543, 460, 171, 876, 796, 607, 650, 81, 837, 545, 591, 946, 846, 521, 913, 636, 878, 735, 414, 372,
             344, 324, 223, 180, 327, 891, 798, 933, 493, 293, 836, 10, 6, 544, 924, 849, 438, 41, 862, 648, 338,
             465, 562, 693, 979, 52, 763, 103, 387, 374, 349, 94, 384, 680, 574, 480, 307, 580, 71, 535, 300, 53,
             481, 519, 644, 219, 686, 236, 424, 326, 244, 212, 909, 202, 951, 56, 812, 901, 926, 250, 507, 739, 371,
             63, 584, 154, 7, 284, 617, 332, 472, 140, 605, 262, 355, 526, 647, 923, 199, 518]

    def __init__(self, capacity=100000000, error_rate=0.0000001, redis_con=None, key="bloomfilter"):
        self.bit_size = math.ceil(capacity * math.log2(math.e) * math.log2(1 / error_rate))  # 所需位数
        self.hash_time = math.ceil(math.log1p(2) * self.bit_size / capacity)  # 最少hash次数
        self.memery = math.ceil(self.bit_size / 8 / 1024 / 1024)  # 占用多少M内存
        self.block_num = math.ceil(self.memery / 512)  # 需要多少个512M的内存块,value的第一个字符必须是ascii码，最多有256个内存块
        self.seeds = self.SEEDS[0:self.hash_time]
        self.key = key
        self.N = 2 ** 31 - 1
        self.hash_func = [SimpleHash(self.bit_size, seed) for seed in self.seeds]
        self.redis_con = redis_con

    def get_key(self, value):
        return self.key + str(int(value[0:2], 16) % self.block_num)

    def is_contains(self, str_input):
        try:
            if not str_input:
                return False
            m5 = md5()
            m5.update(str_input)
            str_input = m5.hexdigest()
            ret = True
            name = self.get_key(str_input)
            for f in self.hash_func:
                loc = f.hash(str_input)
                ret = ret & self.redis_con.getbit(name, loc)
            return ret
        except Exception as e:
            raise

    def insert(self, str_input):
        try:
            m5 = md5()
            m5.update(str_input)
            str_input = m5.hexdigest()
            name = self.get_key(str_input)
            for f in self.hash_func:
                loc = f.hash(str_input)
                self.redis_con.setbit(name, loc, 1)
        except Exception as e:
            raise 
```
#### Test

```python
if __name__ == '__main__':
    bloom_filter_redis_conn_args = {
        "host": "127.0.0.1",
        "port": "6379",
        "db": 0
    }
    redis_con = redis.StrictRedis(connection_pool=redis.ConnectionPool(**bloom_filter_redis_conn_args))
    bloom_filter = BloomFilter(redis_con=redis_con)
    
    start_time = time.time()
    for i in range(6100000, 6101000):
        bloom_filter.insert(str(i).encode("utf-8"))
    print(time.time() - start_time)
    print(bloom_filter.is_contains("6100101".encode("utf-8")))
```

#### 初步结论（本地测试）
- 插入1000条耗时在2-4s之间。
- 插入和查询耗时基本相同。

#### Redis数据查询

```powershell
➜  ~ redis-cli --bigkeys -i 0.1 -h 127.0.0.1

# Scanning the entire keyspace to find biggest keys as well as
# average sizes per key type.  You can use -i 0.1 to sleep 0.1 sec
# per 100 SCAN commands (not usually needed).

[00.00%] Biggest string found so far 'bloomfilter0' with 419346305 bytes

-------- summary -------

Sampled 1 keys in the keyspace!
Total key length in bytes is 12 (avg len 12.00)

Biggest string found 'bloomfilter0' has 419346305 bytes

1 strings with 419346305 bytes (100.00% of keys, avg size 419346305.00)
0 lists with 0 items (00.00% of keys, avg size 0.00)
0 hashs with 0 fields (00.00% of keys, avg size 0.00)
0 streams with 0 entries (00.00% of keys, avg size 0.00)
0 sets with 0 members (00.00% of keys, avg size 0.00)
0 zsets with 0 members (00.00% of keys, avg size 0.00)
```
可以看到 bloomfilter0 所占内存为400M左右
