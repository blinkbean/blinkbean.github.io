---
title: Mac-安装sshpass
comments: true
date: 2021-03-07 19:26:11
author:
tags:
 - Mac
 - sshpass
categories:
---

网上好多都失效了，2019-11-20以下方法亲测可行。
```
brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
```
安装成功后执行 sshpass出现以下效果，说明安装成功。

```
➜  ~ sshpass
Usage: sshpass [-f|-d|-p|-e] [-hV] command parameters
   -f filename   Take password to use from file
   -d number     Use number as file descriptor for getting password
   -p password   Provide password as argument (security unwise)
   -e            Password is passed as env-var "SSHPASS"
   With no parameters - password will be taken from stdin

   -P prompt     Which string should sshpass search for to detect a password prompt
   -v            Be verbose about what you're doing
   -h            Show help (this screen)
   -V            Print version information
At most one of -f, -d, -p or -e should be used
```

安装成功了，那就把密码记下来吧
```
vim ~/.bashrc
```

```
alias jump="sshpass -p '666' ssh host"
```

载入文件 source ~/.bashrc, 具体是哪个文件根据自身情况决定，我把.bashrc 加在了.zshrc里，所以我执行的是`source ~/.zshrc`。

接下来就是验证成果是时候了。

```
➜  ~ jump
Last login: Wed Nov 20 21:59:08 2019 from 172.16.113.151
Welcome to Alibaba Cloud Elastic Compute Service !
```

## Success
