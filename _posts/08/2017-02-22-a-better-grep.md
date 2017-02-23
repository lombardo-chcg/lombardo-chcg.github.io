---
layout: post
title:  "a better grep"
date:   2017-02-22 22:44:20
categories: tools
excerpt: targeting your searches based on file type
tags:
  - bash
---

Today I learned about 2 flags that can be passed to `grep` when searching files for text from the command line: `--include` and `--exclude`.  They are useful for focusing on certain file types when doing a wide ranging search.

For example, say you wanted to search a directory of JavaScript files for some text, but didn't want to see any results from any test files.

Assuming you use the naming convention `testname.spec.js`...

{% highlight bash %}
grep -rn --exclude=\*.spec.js "text I want to find" ./src
{% endhighlight %}

`--include` uses the same syntax.
