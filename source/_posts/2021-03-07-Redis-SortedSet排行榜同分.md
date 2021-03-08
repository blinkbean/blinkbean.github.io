---
title: Redis-SortedSet排行榜同分
comments: true
date: 2021-03-07 18:47:18
author:
tags:
 - Redis
categories:
 - 中间件
---

#### 排行榜可以使用SortedSet，但是如果同分的时候会有两种相对难搞的情况：
1. 谁排名靠前，按需求展示。
2. 同分名次并列。

#### 同分不同名
SortedSet score支持浮点数，只要给每个score加上对应的小数，就能实现按先后达到目标值的排序进行展示。
> 如 1/timestamp 或 1/(时间戳最大值-timestamp)，这里可能有精度问题注意一下。

#### 同分同名次
这时一个SortedSet 就不能满足需求了，因为不知道前面有多少个同分的成员。

 - 两个SortedSet，一个Hash
A SortedSet 放所有排名信息 member score
B SortedSet 放不重复的分数排名 member和score都用A中的score
C Hash记录 score 及 该分数成员的数量

 - 数据更新
分数增加或减少
1.检查C key中原分数下成员的数量，并减1，如果数量为0，删除在 B key中对应分数；检查新的分数是否已经在B key中，如果没有，加进去。
2.C key新的分数下团的数量加1。
3.A key正常增加分数。

- 存在的问题：
两次分页请求可能存在排名变化，导致获取的数据重复的丢失的情况。

- 解决方案：
如果不能接受两次请求间排名变化导致的数据误差，可以给榜单做快照，请求时将快照编号带给服务端来解决。