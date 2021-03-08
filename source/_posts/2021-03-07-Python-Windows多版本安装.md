---
title: Python-Windows多版本安装
comments: true
date: 2021-03-07 19:57:23
author:
tags:
 - Python
categories:
 - 效率工具
---

#### 可能的解决方案
* 安装多个python版本，使用不同的命令进s行版本的区分
```
    C:\Users\hero\python2
    Python 2.7.X
    >>>
    
    C:\Users\hero\python3
    Python 3.X.X
    >>>
    
    两个python版本都装了pip以后怎么办?
    python安装路径找到Scripts文件夹，进入里面找到pip*-script.py，打开修改第一句为要指定的python解释器。
```
* virtualenv
* anaconda(推荐)
* ...(如果有更好的方案再补充)
#### anaconda是什么？
* Anaconda是开源的python发行版本，包含了大量科学包。主要是可以用来进行python的环境管理，也就是说利用Conda可以在同一台机器上进行不同版本python的切换
#### 为什么用anaconda？
* 希望自己的机器上同时拥有不同版本的python，以满足不同代码的需求。
* Windows环境下使用virtualenv对Python进行多版本隔离，但是前提是能安装上多个版本。[笑哭.jpg]
* Win8.1安装Python==3.5==以上提示缺失==api-ms-win-crt-runtime-l1-1-0.dll==问题
#### 怎么安装anaconda？
* 国内镜像地址 : 
> [清华大学开源软件镜像站](https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/)

> [如何安装Anaconda和Python](https://jingyan.baidu.com/article/3f16e0031e87522591c10320.html)

#### 安装anaconda过程
* 安装好anaconda之后会自带：base(root)
的python
* 安装其他版本的python
> * 添加清华镜像(不然安装会超时)
```
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/msys2/
    conda config --set show_channel_urls yes
```
#### Conda命令
```
    conda create --name python27 python=2.7 环境2.7名称python27
    conda create –name cpu 创建一个名为cpu的环境 
    source activate cpu 激活cpu环境 
    source deactivate 禁用当前环境 
    conda remove –name 环境名 –all 
    conda search 软件名 //可以查看到对应的不同版本 
    conda install 软件名 安装软件 
    conda list 查看已安装的package 
    conda list -n 环境名 查看指定环境已安装的package 
    conda install -n 环境名 软件名 指定环境名 安装软件 
    如果不用-n指定环境名称，则被安装在当前活跃环境 
    conda update -n 环境名 软件名 指定环境名更新软件 
    conda remove -n 环境名 软件名 删除指定环境的指定软件包 
    conda env list //查看现有的环境
```


