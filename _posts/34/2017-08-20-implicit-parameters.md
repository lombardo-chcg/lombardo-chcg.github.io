---
layout: post
title:  "implicit parameters"
date:   2017-08-20 19:52:55
categories: languages
excerpt: "understanding implicit parameters and implicit values in scala"
tags:
  - scala
  - jvm
---

My [previous post](/languages/2017/08/19/async-action-in-scala.html) about Scala Futures contained a method that made use of an implicit `ExecutionContext`.  So before we jump into the complexity of an `ExecutionContext` I thought it would be nice to do a basic example of implicit parameters.

There are currently 3 uses of `implicit`'s in Scala, with parameters being one of them (the others being conversions and classes).

An easy way to understand implicit parameters is that they are just like regular parameters, but do not need to be explicitly passed in to a caller.  What qualifies a param as implicit?  It is marked with the `implicit` keyword inside a method signature.  The compiler will search the scope for a type-matching value that is marked with the `implicit` keyword, and plug it into the method.

I'm sure there are some interesting rules that define the appropriate "scope" to search.  Later for those details.  Let's look at a basic example:

`implicitExample.scala`:
{% highlight scala %}
case class MyDataWrapper(id: Int, content: String)

def dataHandler(implicit data: MyDataWrapper): Unit = {
  println(s"data id: ${data.id}")
  println(s"data content: ${data.content}")
}

implicit val myDataInstance = new MyDataWrapper(1, "Hello world, implicits style")

dataHandler
{% endhighlight %}

{% highlight bash %}
scala implicitExample.scala
# data id: 1
# data content: Hello world, implicits style
{% endhighlight %}

So we see that by marking our case class instance with the `implicit` keyword, the associated value has been lifted into some type of "implicit scope" where the compiler can grab it and use it to resolve the reference in the method call.  When we call the method, we don't pass it the param directly. 

This type of thing can get very dangerous and lead to bugs that are very hard to nail down.  Perhaps later we will explore some use cases and how to be responsible with implicit params.
