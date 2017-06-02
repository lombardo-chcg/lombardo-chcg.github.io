---
layout: post
title:  "the lonely operator"
date:   2017-06-01 22:05:47
categories: languages
excerpt: "no more nested if's"
tags:
  - elvis
---

Saw some weird Ruby syntax in a PR that sent me Googling: `&.`

Turns out it was the [Safe navigation operator](https://en.wikipedia.org/wiki/Safe_navigation_operator).

What problem does it solve?

In Object Oriented code, where nasty null values may exist, this type of check is common:

{% highlight ruby %}
if user && user.orders && user.orders.last ...
{% endhighlight %}

The reason for this nasty code is that any of these values could be null which would cause a runtime error.

The point of Safe navigation operator is to be able to walk this minefield in a little bit prettier way, and still not have your problem explode if it hits a null.

{% highlight ruby %}
if user&.orders&.last ...
{% endhighlight %}

Makes it a little easier to read.

--


For me this brings to mind the power of [pattern matching](http://docs.scala-lang.org/tutorials/tour/pattern-matching.html) and the [`Option`](https://www.scala-lang.org/api/current/scala/Option.html) type in Scala, which wraps possible null values.  That way just makes more sense to me.
