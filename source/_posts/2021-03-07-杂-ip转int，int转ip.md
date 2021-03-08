---
title: 杂-ip转int，int转ip
comments: true
date: 2021-03-07 18:24:37
author:
tags:
 - Golang
 - IP
 - Utils
categories:
 - 后端开发
---

#### IP和int之间相互转换

```go
func toInt(ip string) int64 {
	i := 3
	sum := int64(0)
	for j, v := range strings.Split(ip, ".") {
		intV, _ := strconv.ParseInt(v, 10, 64)
		sum = sum + intV*int64(math.Pow(float64(256), float64(i-j)))
	}
	fmt.Println(sum)
	return sum
}

func toIp(num int64) string {
	s := make([]string, 4)
	i := 3
	for i >= 0 {
		s[i] = strconv.FormatInt(num % 256,10)
		num /= 256
		i--
	}
	return strings.Join(s, ".")
}
```
