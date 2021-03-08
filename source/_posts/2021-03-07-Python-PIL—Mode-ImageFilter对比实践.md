---
title: 'Python-PIL—Mode,ImageFilter对比实践'
comments: true
date: 2021-03-07 19:38:56
author:
tags:
 - Python
 - PIL
categories:
 - 后端开发
---

#### 原图
- 学习 一定要找一个好的Object(???)，不然怎么学的下去嘛。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20190727193629193.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpeXV4aW5nNjYzOTgwMQ==,size_16,color_FFFFFF,t_70)

#### 图像的mode
- mode属性是图像的色彩通道的数量和名字，同时也包括像素的类型和颜色深度信息。她们之间的区别可能要放大点才能看得清，比如说一万倍?。

| modes | 描述 |
| --- | --- |
| 1 | 1位像素，黑和白，存成8位的像素 |
| L | 8位像素，黑白 |
| P | 8位像素，使用调色板映射到任何其他模式 |
| RGB | 3*8位像素，真彩 |
| RGBA | 4*8位像素，真彩+透明通道 |
| CMYK | 4*8位像素，颜色隔离 |
| YCbCr | 3*8位像素，彩色视频格式 |
| I | 32位整形像素 |
| F | 32位浮点型像素 |
| RGBX | 有padding的真彩色 |
| HSV |  |
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190727193538101.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpeXV4aW5nNjYzOTgwMQ==,size_16,color_FFFFFF,t_70)
#### 图像滤波器
- 你更喜欢花非花，雾非雾的朦胧，还是线条清晰，棱角分明的透彻。

| Filter | 描述 |
|--|--|
| BLUR | 模糊滤波 |
| CONTOUR | 轮廓滤波 |
| DETAIL | 细节增强滤波 |
| EDGE_ENHANCE | 边缘增强滤波 |
| EDGE_ENHANCE_MORE | 深度边缘增强滤波 |
| EMBOSS | 浮雕滤波 |
| FIND_EDGES | 寻找边缘信息的滤波 |
| SMOOTH | 平滑滤波 |
| SMOOTH_MORE | 深度平滑滤波 |
| SHARPEN | 锐化滤波 |

![在这里插入图片描述](https://img-blog.csdnimg.cn/2019072719355829.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpeXV4aW5nNjYzOTgwMQ==,size_16,color_FFFFFF,t_70)
#### 原代码
```python
#!/usr/local/env python
# -*- coding: utf-8 -*-
from PIL import Image, ImageDraw, ImageFont, ImageFilter

font_posotion = 20,20
color =  255,0,0,255
font = ImageFont.truetype('Arial.ttf', size=25, encoding="unic")
thumbnail_size = 400,400
row_count = 4


def create_thumbnail(src_file):
    size = thumbnail_size
    im = Image.open(src_file)

    im.thumbnail(size, Image.ANTIALIAS)
    return im


class MyFilter(object):
    BLUR = "BLUR"
    CONTOUR = "CONTOUR"
    DETAIL = "DETAIL"
    EDGE_ENHANCE = "EDGE_ENHANCE"
    EDGE_ENHANCE_MORE = "EDGE_ENHANCE_MORE"
    EMBOSS = "EMBOSS"
    FIND_EDGES = "FIND_EDGES"
    SMOOTH = "SMOOTH"
    SMOOTH_MORE = "SMOOTH_MORE"
    SHARPEN = "SHARPEN"

    FilterList = [BLUR, CONTOUR, DETAIL,
                  EDGE_ENHANCE, EDGE_ENHANCE_MORE, EMBOSS,
                  FIND_EDGES, SMOOTH, SMOOTH_MORE,
                  SHARPEN]

    ImageFilterList = [ImageFilter.BLUR, ImageFilter.CONTOUR, ImageFilter.DETAIL,
                       ImageFilter.EDGE_ENHANCE, ImageFilter.EDGE_ENHANCE_MORE, ImageFilter.EMBOSS,
                       ImageFilter.FIND_EDGES, ImageFilter.SMOOTH, ImageFilter.SMOOTH_MORE,
                       ImageFilter.SHARPEN]

class MyMode(object):
    MODE1 = "1"
    L = "L"
    I = "I"
    F = "F"
    P = "P"
    RGB = "RGB"
    RGBX = "RGBX"
    RGBA = "RGBA"
    CMYK = "CMYK"
    YCbCr = "YCbCr"
    # LAB = "LAB"
    HSV = "HSV"

    ModeList = [MODE1, L, I, F, P, RGB, RGBX, RGBA, CMYK, YCbCr, HSV]

def get_position(count):

    width = thumbnail_size[0]
    pic_width = width*row_count
    position = (count * width)%pic_width, (count * width)/pic_width*width
    return position

def get_pic_size(thumbnail_size, pic_num, row_count):
    pic_width = thumbnail_size[0] * row_count
    extra_row = 1 if pic_num % row_count else 0
    pic_height = (pic_num / row_count + extra_row) * thumbnail_size[1]

    return pic_width, pic_height

def create_filter(src_file):
    count = 0
    pic_size = get_pic_size(thumbnail_size, len(MyFilter.FilterList), row_count)
    image = Image.new("RGBA", pic_size, "white")
    thumbnail_im = create_thumbnail(src_file)

    for i in range(0, len(MyFilter.FilterList)):
        CONTOURimg = thumbnail_im.copy()
        CONTOUR = CONTOURimg.filter(MyFilter.ImageFilterList[count])
        CONTOURdraw = ImageDraw.Draw(CONTOUR)
        CONTOURdraw.text(font_posotion, MyFilter.FilterList[count], font=font, fill=color)
        image.paste(CONTOUR, get_position(count))
        count += 1

    # image.save("filter.jpg")
    image.show()

def create_mode(src_file):
    count = 0
    pic_size = get_pic_size(thumbnail_size, len(MyMode.ModeList), row_count)
    image = Image.new("RGBA", pic_size, "white")
    thumbnail_im = create_thumbnail(src_file)

    for i in range(0, len(MyMode.ModeList)):
        img = thumbnail_im.copy()
        CONTOURdraw = ImageDraw.Draw(img)
        CONTOURdraw.text(font_posotion, MyMode.ModeList[count], font=font, fill=color)

        CONTOUR = img.convert(MyMode.ModeList[i])

        image.paste(CONTOUR, get_position(count))
        count += 1

    # image.save("mode.jpg")
    image.show()


if __name__ == '__main__':
    create_mode("res.jpg")
    create_filter("res.jpg")
    

```
