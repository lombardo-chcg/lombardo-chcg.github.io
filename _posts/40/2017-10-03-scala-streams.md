---
layout: post
title:  "scala streams"
date:   2017-10-03 22:28:37
categories: languages
excerpt: "lazy evaluation of a collection using scala's stream class"
tags:
  - functional
  - scala
---

Lazy Instantiation is a common pattern in software.  I've seen it be used in dependency injection inside a web service.  It turns out that Scala offers a similar behavior in their [Stream](http://www.scala-lang.org/api/2.12.3/scala/collection/immutable/Stream.html) class.  

Here's how I understand it:
* a `List` in Scala comprises of a `head` element, which is the first item in the list
* it also comprises of a `tail`, which are all the other elements.

{% highlight scala %}
val x = List(1,2,3,4,5)
x.head
// 1
x.tail
// List(2, 3, 4, 5)

{% endhighlight %}

A `Stream` is similar to a list, but the difference is that the `tail` hasn't been fully computed at the time of instantiation.  From what I've been reading, applying this concept of Lazy Evaluation to a collection is a standard feature of functional programming.

While a `Stream` is theoretically infinite, it is possible to force an evaluation of the full stream which will quickly blow the memory on your JVM:

{% highlight scala %}
// warning: this will fail spectacularly if you run in a REPL
lazy val x = Stream.from(2)
x.last
{% endhighlight %}

I'm having trouble thinking of use cases for everyday programming, but I can imagine `Stream`s being a powerful tool for algorithms.  For example here's a use case for the classic factorial solve:

{% highlight scala %}
def factorial(n: Int):Int = {
  Stream.from(1).take(n).foldLeft(1)(_ * _)
}

factorial(10)

// 3628800
{% endhighlight %}

I've also seen some examples of prime number sieves using this `Stream` class.  I hope to explore that in a future post.
