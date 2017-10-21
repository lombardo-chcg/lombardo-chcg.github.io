---
layout: post
title:  "windowing a collection in scala"
date:   2017-10-21 17:39:19
categories: languages
excerpt: "using a scala built-in to compare collection elements"
tags:
  - scala
  - functional
---

I was recently working on [Project Euler Problem 47](https://projecteuler.net/problem=47), which requires the solver to find consecutive integers that each have a given number of distinct prime factors.

This gave me a reason to dive into the Scala collection methods, where I discovered `sliding`

> Groups elements in fixed size blocks by passing a "sliding window" over them

{% highlight scala %}
Stream.from(1).take(5).sliding(3).toList

// List(Stream(1, 2, 3), Stream(2, 3, 4), Stream(3, 4, 5))
{% endhighlight %}

Sliding provide a great way to do "introspection" on a collection, giving the programmer the ability to compare an element to its neighbors.  

Turns out that `sliding` has 2 signatures, one which takes only the window size, and another which takes window size and also step size.  

{% highlight scala %}
Stream.from(1).take(5).sliding(3, 2).toList

// List(Stream(1, 2, 3), Stream(3, 4, 5))
{% endhighlight %}

Here's how I ended up solving PE47: [`Euler47.scala`](https://github.com/lombardo-chcg/functional_euler/blob/master/src/main/scala/com/lombardo/app/problems/Euler47.scala)
