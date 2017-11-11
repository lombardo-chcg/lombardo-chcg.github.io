---
layout: post
title:  "closures in scala"
date:   2017-11-11 12:20:45
categories: languages
excerpt: "using a closure to show a counter example"
tags:
  - scala
  - functional
---

#### Write a "factory function" that returns a function which implements a counter.

We can do this using Scala's amazingly concise syntax, using a closure to encapsulate the mutable counter state.

{% highlight scala %}
val counterF = () => {
  var c = 0
  () => {
    c += 1
    c
  }
}

val counter = counterF()
counter()
// 1
counter()
// 2

val counter2 = counterF()
counter2()
// 1
counter()
// 3
{% endhighlight %}

Compare to an object-oriented approach:

{% highlight scala %}
class Counter() {
  private var count: Int = 0

  def inc: Int = {
    count += 1
    count
  }

  def dec: Int = {
    count -= 1
    count
  }
}

val counterF = () => new Counter()

val counter = counterF()

counter.inc
// 1
counter.inc
// 2
counter.dec
// 1
{% endhighlight %}
