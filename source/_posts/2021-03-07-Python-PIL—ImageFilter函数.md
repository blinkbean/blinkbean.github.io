---
title: Python-PIL—ImageFilter函数
comments: true
date: 2021-03-07 19:34:16
author:
tags:
 - Python
 - PIL
categories:
 - 后端开发
---

[参考地址](https://blog.csdn.net/icamera0/article/details/50708888)
#### 滤镜函数
##### 先看效果
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190729010351783.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpeXV4aW5nNjYzOTgwMQ==,size_16,color_FFFFFF,t_70)
##### Kernel
> Kernel(size, kernel, scale=None, offset=0)
- 生成给定尺寸的卷积核，变量的size必须为(3, 3) 或(5, 5)。
- kernel与size对应，必须为9或25个整数或浮点数。
- 如果设置scale，则卷积核作用于每个像素之后都要除以scale值，默认值为卷积核的权重之和。
- 如果设置offset，则将offset值与卷积核相加，然后除以scale

```python
im = Image.open(src_file)
Kernel_im = im.filter(ImageFilter.Kernel((3,3),(1,1,1,0,0,0,2,0,2)))
```

##### RankFilter
> RankFilter(size, rank)
- 等级滤波器。
- 对于输入图像的每个像素点，等级滤波器根据像素值，在(size, size) 的区域中对所有像素点进行排序，然后拷贝对应等级的值存储到输出图像中。
- size，以像素点为中心size * size 的像素点中进行排序。
- rank，size * size 的像素中选择排序第rank位的像素作为新值。

```python
im = Image.open(src_file)
im = im.filter(ImageFilter.RankFilter(5,24))
```

##### MinFilter, MedianFilter,MaxFilter
> MinFilter(size)
> 最小滤波器。
> MedianFilter(size)
> 中值滤波器。
> MaxFilter(size)
> 最大滤波器。
- size，以像素点为中心的(size * size) 区域中选择最小、中值、最大的像素作为新值。

```python
im = Image.open(src_file)
im = im.filter(ImageFilter.MinFilter(5))
im = im.filter(ImageFilter.MedianFilterFilter(5))
im = im.filter(ImageFilter.MaxFilter(5))
```

##### ModeFilter
> ModeFilter(size)
- 模式滤波器
- size，以像素点为中心的(size * size)区域中选择出现次数最多的像素最为新值。

```python
im = Image.open(src_file)
im = im.filter(ImageFilter.ModeFilter(5))
```

