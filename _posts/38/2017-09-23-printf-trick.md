---
layout: post
title:  "printf tricks"
date:   2017-09-23 09:36:50
categories: tools
excerpt: "couple of handy techniques for formatting output in the terminal"
tags:
  - bash
  - unix
---

Variable assignment:
{% highlight bash %}
printf -v USER_EMAIL $(curl https://jsonplaceholder.typicode.com/comments/1 | jq -r ".email")
{% endhighlight %}

`print-table.sh`:
{% highlight bash %}
#!/bin/bash

# print headers
printf "%-25s %-25s %s\n" ID VALUE TIME
# print whitespace and "tr" it to dashes for header divider
printf "%*s-----\n" 75 | tr ' ' "-"
# print values with standard formatting
for i in $(seq 0 10); do
  printf "%-25s %-25s %s\n" $i $(( $i * $i )) "$(date)"
done

# ID                        VALUE                     TIME
# --------------------------------------------------------------------------------
# 0                         0                         Sat Sep 23 09:57:55 CDT 2017
# 1                         1                         Sat Sep 23 09:57:55 CDT 2017
# 2                         4                         Sat Sep 23 09:57:55 CDT 2017
# 3                         9                         Sat Sep 23 09:57:55 CDT 2017
# 4                         16                        Sat Sep 23 09:57:55 CDT 2017
# 5                         25                        Sat Sep 23 09:57:55 CDT 2017
# 6                         36                        Sat Sep 23 09:57:55 CDT 2017
# 7                         49                        Sat Sep 23 09:57:55 CDT 2017
# 8                         64                        Sat Sep 23 09:57:55 CDT 2017
# 9                         81                        Sat Sep 23 09:57:55 CDT 2017
# 10                        100                       Sat Sep 23 09:57:55 CDT 2017

{% endhighlight %}
