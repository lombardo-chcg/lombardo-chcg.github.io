---
layout: post
title:  "sealed abstract"
date:   2017-10-08 20:31:53
categories: languages
excerpt: "using the sealed keyword in scala"
tags:
  - scala
  - trait
  - inheritance
  - class
---

When reading source code I have come across the `sealed` keyword in Scala programs.

Its actually a great concept:

> Traits and classes can be marked sealed which means all subtypes must be declared in the same file. This assures that all subtypes are known.

[*source*](https://docs.scala-lang.org/tour/pattern-matching.html)

{% highlight scala %}
sealed trait User {
  def email: String
  def name: String
}

class FreeUser extends User {
  def email: String = ???
  def name: String = ???
}

class PremiumUser extends User {
  def email: String = ???
  def name: String = ???
}
{% endhighlight %}
