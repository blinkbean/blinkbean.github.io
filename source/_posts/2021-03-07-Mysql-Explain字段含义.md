---
title: Mysql-Explain字段含义
comments: true
date: 2021-03-07 18:39:10
author:
tags:
 - Mysql
categories:
 - 数据库
---

# [mysql explain用法和结果的含义](https://www.cnblogs.com/yycc/p/7338894.html)

### explain或desc显示了mysql如何使用索引来处理select语句以及连接表。可以帮助选择更好的索引和写出更优化的查询语句。

> explain 数据表 或 desc 数据表
>
> 显示数据表各字段含义

> explain sql 或desc sql
>
> 显示sql执行效率

### explain列解释

1. ==table== 输出的行所引用的表

2. ==select_type== select类型

   > - **SIMPLE**:简单SELECT(不使用UNION或子查询)
   > - **PRIMARY**:最外面的SELECT
   > - **UNION**:UNION中的第二个或后面的SELECT语句
   > - **DEPENDENT UNION**:UNION中的第二个或后面的SELECT语句,取决于外面的查询
   > - **UNION RESULT**:UNION 的结果
   > - **SUBQUERY**:子查询中的第一个SELECT
   > - **DEPENDENT SUBQUERY**:子查询中的第一个SELECT,取决于外面的查询
   > - **DERIVED**:导出表的SELECT(FROM子句的子查询)

3. ==type== 这是重要的列，显示连接使用了何种类型。

   > 结果值从好到坏依次是：
   >
   > system > const > eq_ref > ref > fulltext > ref_or_null > index_merge > unique_subquery > index_subquery > range > index > ALL
   > - **system**:表仅有一行(=系统表)。这是const联接类型的一个特例。
   > - **const**:表最多有一个匹配行,它将在查询开始时被读取。因为仅有一行,在这行的列值可被优化器剩余部分认为是常数。const表很快,因为它们只读取一次!
   > - **eq_ref**:对于每个来自于前面的表的行组合,从该表中读取一行。这可能是最好的联接类型,除了const类型。
   > - **ref**:对于每个来自于前面的表的行组合,所有有匹配索引值的行将从这张表中读取。
   > - **ref_or_null**:该联接类型如同ref,但是添加了MySQL可以专门搜索包含NULL值的行。
   > - **index_merge**:该联接类型表示使用了索引合并优化方法。
   > - **unique_subquery**:该类型替换了下面形式的IN子查询的ref: value IN (SELECT primary_key FROM single_table WHERE some_expr) unique_subquery是一个索引查找函数,可以完全替换子查询,效率更高。
   > - **index_subquery**:该联接类型类似于unique_subquery。可以替换IN子查询,但只适合下列形式的子查询中的非唯一索引: value IN (SELECT key_column FROM single_table WHERE some_expr)
   > - **range**:只检索给定范围的行,使用一个索引来选择行。
   > - **index**:该联接类型与ALL相同,除了只有索引树被扫描。这通常比ALL快,因为索引文件通常比数据文件小。
   > - **ALL**:对于每个来自于先前的表的行组合,进行完整的表扫描。

3. ==possible_keys== 指出MySQL能使用哪个索引在该表中找到行。

4. ==key== 实际使用的索引。如果为NULL，则没有使用索引。很少的情况下，MYSQL会选择优化不足的索引。

   > 可以在SELECT语句中使用USE INDEX（indexname）、force index(indexname) 来强制使用一个索引或者用IGNORE INDEX（indexname）来强制MYSQL忽略索引

5. ==key_len== 使用的索引的长度。在不损失精确性的情况下，长度越短越好。如果键是NULL,则长度为NULL。

6. ==ref== 显示使用哪个列或常数与key一起从表中选择行。

7. ==rows== MYSQL认为必须检查的用来返回请求数据的行数。

8. ==extra== 关于MYSQL如何解析查询的额外信息。

   > 坏的例子是**Using temporary**和**Using filesort**，意思MYSQL根本不能使用索引，结果是检索会很慢。
   >
   > - distinct: 一旦MYSQL找到了与行相联合匹配的行，就不再搜索了。
   > - not exists: MYSQL优化了LEFT JOIN，一旦它找到了匹配LEFT JOIN标准的行，就不再搜索了。
   > - range checked for each Record（index map:#）:MySQL没有发现好的可以使用的索引,但发现如果来自前面的表的列值已知,可能部分索引可以使用。这是使用索引的最慢的连接之一。
   > - **using filesort**: 看到这个的时候，查询就需要优化了。**MYSQL需要进行额外的步骤来发现如何对返回的行排序**。它根据连接类型以及存储排序键值和匹配条件的全部行的行指针来排序全部行。
   > - using index: 从只使用索引树中的信息而不需要进一步搜索读取实际的行来检索表中的列信息。
   > - using temporary 看到这个的时候，查询需要优化了。为了解决查询,MySQL需要创建一个临时表来容纳结果。这通常发生在对不同的列集进行ORDER BY上，而不是GROUP BY上。
   > -  where used 使用了WHERE从句来限制哪些行将与下一张表匹配或者是返回给用户。如果不想返回表中的全部行，并且连接类型ALL或index，这就会发生，或者是查询有问题不同连接类型的解释（按照效率高低的顺序排序）
   > -  system 表只有一行：system表。这是const连接类型的特殊情况。
   > -  const 表中的一个记录的最大值能够匹配这个查询（索引可以是主键或惟一索引）。因为只有一行，这个值实际就是常数，因为MYSQL先读这个值然后把它当做常数来对待。
   > - eq_ref 在连接中，MYSQL在查询时，从前面的表中，对每一个记录的联合都从表中读取一个记录，它在查询使用了索引为主键或惟一键的全部时使用。
   > - ref 这个连接类型只有在查询使用了不是惟一或主键的键或者是这些类型的部分（比如，利用最左边前缀）时发生。对于之前的表的每一个行联合，全部记录都将从表中读出。这个类型严重依赖于根据索引匹配的记录多少—越少越好。
   > - range 这个连接类型使用索引返回一个范围中的行，比如使用>或<查找东西时发生的情况。
   > - index 这个连接类型对前面的表中的每一个记录联合进行完全扫描（比ALL更好，因为索引一般小于表数据）。
   > - ALL 这个连接类型对于前面的每一个记录联合进行完全扫描，这一般比较糟糕，应该尽量避免。

9. ==filtered== 显示了通过条件过滤出的行数的百分比估计值。