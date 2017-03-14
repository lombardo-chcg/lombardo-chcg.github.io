---
layout: post
title:  "improving grep skills"
date:   2017-03-13 20:31:27
categories: tools
excerpt: "quick tip for better grep'ing"
tags:
  - bash
---

Found myself needing to search a large directory for a string, not knowing or caring about the capitalization of the string.  Of course there's a flag for that:

{% highlight bash %}
grep -irn iDonTcAReaboutTheCaSe directory_name/
{% endhighlight %}

As a review the `-r` does a recursive search of a directory and `-n` prints the line number.

The `i` for case-insensitive is common in RegEx pattern matching:

{% highlight javascript %}
"lets make all the t's uppercase".replace(/t/gi, 'T');
{% endhighlight %}

This is a JavaScript sample that does a **g**lobal, case-**i**nsensitive replacement of `t` to `T` in the target string.
