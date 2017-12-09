---
layout: post
title:  "scala function map"
date:   2017-12-09 08:11:20
categories: languages
excerpt: "creating a function library using a Map"
tags:
  - scala
  - functional
  - jvm
---

Here's a cool way to use anonomous function blocks as Scala `Map` values.

Use case: I need a library of transformations for user input living in memory and I want to match on User Input.

{% highlight scala %}

case object Add
case object Subtract

val functionLibrary = Map(
  Add -> { (x: Int, y: Int) => x + y },
  Subtract -> { (x: Int, y: Int) => x - y }
)

functionLibrary(Add)(10,20)

functionLibrary(Subtract)(10,20)

{% endhighlight %}

I like using `case objects` in this way as it leverages the Scala type system.  `case objects` also have a handy `toString` built in.
