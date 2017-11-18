---
layout: post
title:  "more on scala Streams"
date:   2017-11-18 14:54:51
categories: languages
excerpt: "using the Scala Stream class in problem-solving"
tags:
  - functional
  - euler
---

Been a crazy week of Hackathon with no energy for `standard in`!  Back today with some more fundamentals.  The Scala [`Stream`](http://www.scala-lang.org/api/2.12.3/scala/collection/immutable/Stream.html) class is very handy for problem-solving like with Project Euler.  I've been using it as an alternative to the imperative style looping, i.e. using a mutable counter and incrementing it until a condition is met.

Use case one: `Stream` all numbers from 1 until a condition is met

Example in the wild: [Project Euler Problem 52](https://projecteuler.net/problem=52)

Turn a number into a canonical representation:
{% highlight scala %}
def getCanonical(n: Int): String = n.toString.split("").sorted.mkString

(e.getCanonical(125874) == e.getCanonical(251748)) should be(true)
{% endhighlight %}


Given `n: Int`, for `i <- 2 to 6`, return true if `getCanonical(n * i)` is equal in all cases
{% highlight scala %}
def allAreSame(n: Int): Boolean = {
    (2 to 6).map(_ * n).map(getCanonical).distinct.size == 1
}
{% endhighlight %}

Stream lazily until the condition is met
{% highlight scala %}
Stream.from(1).find(allAreSame)
// Option[142857]
{% endhighlight %}

--

Use case two: given a map function `f = (Int) => Int` and a value, `max: Int`, find all values of `n` where `f(n) < max`

Example in the wild: [Project Euler Problem 42](https://projecteuler.net/problem=42)

Map function
{% highlight scala %}
def computeTriangle(n: Int): Int = ((0.5 * n) * (n + 1)).toInt
{% endhighlight %}

Return `Stream` where `f(n) < max`
{% highlight scala %}
def triNumsUnder(max: Int): Stream[Int] = {
    Stream.from(1).map(computeTriangle).takeWhile(_ < max)
}

e.triNumsUnder(56).toList should be(List(1, 3, 6, 10, 15, 21, 28, 36, 45, 55))
{% endhighlight %}

Rest of my solution [here](https://github.com/lombardo-chcg/functional_euler/blob/master/src/main/scala/com/lombardo/app/problems/Euler42.scala)
