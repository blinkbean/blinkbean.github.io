---
title: Mysql-自增列AUTO_INCREMENT
comments: true
date: 2021-03-07 18:52:58
author:
tags:
 - Mysql
categories:
 - 数据库
---

### AUTO_INCREMENT
###### 两种情况

1、在载入语句执行前，已经**不确定**要插入多少条记录。

- 在执行插入语句时在==表级别==加一个==auto-inc锁==，然后为每条待插入记录的auto-increment修饰的列分配递增的值，语句执行结束后，再把auto-inc锁释放掉。一个事务再持有auto-inc锁的过程中，其他事务的插入语句都要被阻塞，可以保证一个语句中分配的递增值是连续的。
> AUTO-INC锁的作用范围只是单个插入语句，插入语句执行完成后，这个锁就被释放了，跟我们之前介绍的锁在事务结束时释放是不一样的。

2、插入语句执行前就**确定**要插入多少条记录。
- 采用一个轻量级的锁，在为插入语句生成auto-increment修饰的列的值时获取一下这个轻量级锁，生成需要用到的auto-increment列的值后，==立马释放==，不需要等语句执行。

> InnoDB中提供系统变量 innodb_autoinc_lock_mode 控制用以上哪种方式进行自增的赋值。
> 1. innodb_autoinc_lock_mode=0 一律采用auto-inc锁。
> 2. innodb_autoinc_lock_mode=2 一律采用轻量级锁。
> 3. innodb_autoinc_lock_mode=1 混着来，插入记录数量确定时采用轻量级锁，不确定时使用AUTO-INC锁。
> 
> 当一律采用轻量级锁时，可能会造成不同事物中插入语句生成的值时交叉的，在有主从复制的场景中是不安全的。
