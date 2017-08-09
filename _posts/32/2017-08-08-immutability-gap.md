---
layout: post
title:  "immutability gap"
date:   2017-08-08 21:32:53
categories: languages
excerpt: "a gotcha in the scala immutability game"
tags:
  - scala
  - functional
---

One of the cool things about learning Scala is the concept of `val`.  This keyword creates a "fixed value" which cannot be modified.

Or so I thought...

While working today in a Scala project using a 3rd party Java library, I was bitten by a gotcha which I will demonstrate here:

{% highlight scala %}
case class DemoClass(var mutableProp: String, immutableProp: String)

val demo = new DemoClass("watch me go", "watch me stay")

demo.mutableProp = "gone"

demo
// res3: DemoClass = DemoClass("gone", "watch me stay")

demo.immutableProp = "not gonna happen"
// cmd4.sc:1: reassignment to val
// val res4 = demo.immutableProp = "not gonna happen"
//
{% endhighlight %}

So what's happening here?

A `val` is created (`demo`) which is an instance of `DemoClass`.

`DemoClass` contains a property that is a `var`, meaning that it is mutable in the Scala world.

So while `demo` is a "fixed value", we are still able to modify its internal properties.

A heavy-handed example, to be sure.  But I think it demonstrates my point that just cause a top-level object is defined as a `val` doesn't mean it is frozen in stone.  

--

*special note: today marks my 1 year anniversary as a software developer at [Uptake](https://uptake.com/)!  I'm so happy and fortunate to be able to work for such a great company, full of totally brilliant people, where I get to learn awesome stuff every day.  Cheers to 1 year.*
