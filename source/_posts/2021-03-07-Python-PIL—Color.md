---
title: Python-PIL—Color
comments: true
date: 2021-03-07 19:35:38
author:
tags:
 - Python
 - PIL
categories:
 - 后端开发
---

#### ImageColor
##### 十六进制
- 共六位前两位表示R，中间两位表示G，后两位表示B 如：#ff0000

##### RGB
- 如：rgb(255, 0, 0)、rgb(100%, 0%, 0%)

##### HSL(Hue-Saturation-Ligntness)
- hsl(hue, saturation%, lightness%)
- hue 为[0, 360], red=0, green=120, blue=240
- saturation 为[0%, 100%] gray=0, full=100%
- lightness 为[0%, 100%] black=0, normal=50%, white=100%
- 如：hsl(0, 100%, 50%)

##### Getrgb
- 六种方法获取红色tuple值
```python
ImageColors.getrgb("ff0000")
# (255,0,0)
ImageColors.getrgb("rgb(255,0,0)")
# (255,0,0)
ImageColors.getrgb("rgb(100%,0%,0%)")
# (255,0,0)
ImageColors.getrgb("hsl(0,100%,50%)")
# (255,0,0)
ImageColors.getrgb("red") # 不是每个颜色类型的单词都可以这样用，pil中罗列了常用的颜色
# (255,0,0)
ImageColors.getrgb("Red")
# (255,0,0)
```


