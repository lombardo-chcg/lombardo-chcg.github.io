---
layout: post
title:  "bash: play nice with strings"
date:   2017-05-24 21:16:24
categories: tools
excerpt: "manipulating strings with bash"
tags:
  - bash
---

Let's say you have system access to a very long sting, like a git commit SHA.

You want to use the SHA to identify something related to the commit, but you don't need the whole string.  Just enough of it to make sure it is unique.  Lets say the first 10 or 11 characters.  [here's some reasoning behind that size](https://git-scm.com/book/en/v2/Git-Tools-Revision-Selection)

No prob.  bash gives us an easy to to access a substring within a larger string, using [Parameter Expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html).

{% highlight bash %}
commitSha="21093b6686d69d97d6a84d3b8c8ce71cb77aa268"

miniSha=${commitSha:0:11}

echo $miniSha
#=> 21093b6686d
{% endhighlight %}
