---
layout: post
title:  "hand-rolled map"
date:   2017-03-20 22:16:29
categories: languages
excerpt: "rolling my own map function in scala"
tags:
  - scala
  - functional
---

[I was watching this awesome talk tonight by Kelsey Gilmore-Innis](http://nerd.kelseyinnis.com/blog/2013/11/12/idiomatic-scala-the-for-comprehension/) and it got me thinking about Scala's source code.  So I decided to dive into the code and read their implementation of the standard `map` function over a collection.  

Well, read is a strong word.  More like stare at the screen that contained Scala source code and attempt to decipher it.
[Here's where I wound up](https://github.com/scala/scala/blob/419a6394045a0615cb996152b04c92d25f9fb700/src/library/scala/collection/immutable/List.scala#L281).

Got tired, couldn't find it, decided to write a quick implementation to test my understanding of a for/yield or a for-comprehension.

Basically, it's a function that takes a list and another function as args, and returns a new list with the passed-in function applied to each member of the original list.

{% highlight scala %}
def map(collection: List[Int], func: Int => Int): List[Int] = {
  val output = for {
    item <- collection
  } yield {
    func(item)
  }

  output
}

val nums = List(1,2,3,4,5)

val addOne = map(nums, { num: Int => num + 1 })
println(addOne)
// List(2, 3, 4, 5, 6)

val squared = map(nums, { num: Int => num * num })
println(squared)
List(1, 4, 9, 16, 25)
{% endhighlight %}
