---
title: 'Python-PIL—Transpose,Blend,Split,Composite'
comments: true
date: 2021-03-07 19:37:52
author:
tags:
 - Python
 - PIL
categories:
 - 后端开发
---

#### Transpose 方向变换
- 横看成岭侧成峰，好不容易有了Object，还不从各个方向都欣赏一下。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20190727215620420.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpeXV4aW5nNjYzOTgwMQ==,size_16,color_FFFFFF,t_70)
#### Blend 调节透明度并合并
- 	前提：两张图片的尺寸和模式一致。
- 一张图想同时放两个Object，也不是不可以，但是图这两个Object怎么分配资源？当然是55开还是28开都可以，原则就是你只有两者的和为1。
> - 合并公式：res_img = image1 * (1 - alpha) + image2 * alpha

![在这里插入图片描述](https://img-blog.csdnimg.cn/20190727220007302.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpeXV4aW5nNjYzOTgwMQ==,size_16,color_FFFFFF,t_70)
#### Split RGB通道
每张图片都是有红绿蓝三个通道的，split方法可以将三个通道分离，像不像三种肤色的Object。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190727220155886.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpeXV4aW5nNjYzOTgwMQ==,size_16,color_FFFFFF,t_70)
#### Composite 两张图片合并，并加入mask图像作为透明度。
- 前提：image1, image2, mask 图片的尺寸和模式一致。
相当于Photoshop里的通道蒙版，下图效果不是特别好，可以注意一下图1的嘴，颜色没有图2、3明显。拿自己的Object试试看，可能对比效果会好一点。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190727220505748.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpeXV4aW5nNjYzOTgwMQ==,size_16,color_FFFFFF,t_70)
#### 原代码
```python
#!/usr/local/env python
# -*- coding: utf-8 -*-
from PIL import Image, ImageFont, ImageDraw

font_posotion = 20,20
color =  255,0,0,255
font = ImageFont.truetype('Arial.ttf', size=25, encoding="unic")
thumbnail_size = 400,400
row_count = 3


def create_thumbnail(src_file):
    size = thumbnail_size
    im = Image.open(src_file)

    im.thumbnail(size, Image.ANTIALIAS)
    return im

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


class MyTranspose(object):
    FLIP_LEFT_RIGHT = "FLIP_LEFT_RIGHT"
    FLIP_TOP_BOTTOM = "FLIP_TOP_BOTTOM"
    ROTATE_90 = "ROTATE_90"
    ROTATE_180 = "ROTATE_180"
    ROTATE_270 = "ROTATE_270"
    TRANSPOSE = "TRANSPOSE"

    TransposeList = [FLIP_LEFT_RIGHT,FLIP_TOP_BOTTOM,ROTATE_90,ROTATE_180,ROTATE_270,TRANSPOSE]
    ImageTransposeList = [Image.FLIP_LEFT_RIGHT,Image.FLIP_TOP_BOTTOM,Image.ROTATE_90,
                          Image.ROTATE_180,Image.ROTATE_270,Image.TRANSPOSE]

class MySplit(object):
    R = "R"
    G = "G"
    B = "B"

    SplitList = [R, G, B]

def create_transpose(src_file):
    # 方向变换
    count = 0
    pic_size = get_pic_size(thumbnail_size, len(MyTranspose.TransposeList), row_count)
    image = Image.new("RGBA", pic_size, "white")
    thumbnail_im = create_thumbnail(src_file)
    for i in range(0, len(MyTranspose.TransposeList)):
        img = thumbnail_im.copy()
        CONTOURimg = img.transpose(MyTranspose.ImageTransposeList[i])
        CONTOURdraw = ImageDraw.Draw(CONTOURimg)
        CONTOURdraw.text(font_posotion, MyTranspose.TransposeList[count], font=font, fill=color)
        image.paste(CONTOURimg, get_position(count))
        count+=1
    CONTOURimg = thumbnail_im.copy()
    CONTOURdraw = ImageDraw.Draw(CONTOURimg)
    CONTOURdraw.text(font_posotion, "ORIGINAL PIC", font=font, fill=color)
    image.paste(CONTOURimg, get_position(count))
    # image.show()
    image.save("transpose.jpg")

def create_blend(src_file):
    # 合并
    img = Image.open(src_file)
    copy_img = img.transpose(Image.FLIP_LEFT_RIGHT)
    res_img = Image.blend(img, copy_img, 0.5)

    res_img.show()

def create_composite(src_file):
    # 蒙版工具
    count = 0
    mask_name = ["R","G","B"]
    image = Image.new("RGBA", (1200,400), "white")
    thumbnail_im = create_thumbnail(src_file)
    for i in range(0, 3):
        print i
        copy_img = thumbnail_im.transpose(Image.FLIP_LEFT_RIGHT)
        res_img = Image.blend(thumbnail_im, copy_img, 0.5)
        my_split = res_img.split()
        im = Image.composite(thumbnail_im, res_img, my_split[i])
        CONTOURdraw = ImageDraw.Draw(im)
        CONTOURdraw.text(font_posotion, "mask: %s" % mask_name[i], font=font, fill=color)
        image.paste(im, get_position(count))
        count += 1
    image.save("composite.jpg")
    # image.show()

def create_split(src_file):
    # 图层
    count = 0
    pic_size = get_pic_size(thumbnail_size, len(MySplit.SplitList), row_count)
    image = Image.new("RGBA", pic_size, "white")
    thumbnail_im = create_thumbnail(src_file)
    for i in range(0, len(MySplit.SplitList)):
        CONTOURimg = thumbnail_im.split()[i].copy()
        CONTOURdraw = ImageDraw.Draw(CONTOURimg)
        CONTOURdraw.text(font_posotion, MySplit.SplitList[count], font=font)
        image.paste(CONTOURimg, get_position(count))
        count += 1

    # image.show()
    image.save("split.jpg")

if __name__ == '__main__':
    # create_transpose("res.jpg")
    # create_split("res.jpg")
    # create_blend("res.jpg")
    create_composite("res.jpg")

```
