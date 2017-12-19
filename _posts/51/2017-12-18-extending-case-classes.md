---
layout: post
title:  "extending case classes"
date:   2017-12-18 18:52:39
categories: languages
excerpt: "using traits to extend case classes in scala"
tags:
  - scala
  - jvm
  - object
  - ooo
---

While Scala `case class`es are best used to represent Data objects, it can be handy to extend their behavior beyond the standards set in the Scala language.

For example, a "composite getter", `#fullName` that combines two constructor parameters, `firstName` and `lastName`:

{% highlight scala %}
trait Person {
  val firstName: String
  val lastName: String
  def fullName: String = s"$firstName $lastName"
}

case class Student(firstName: String, lastName: String) extends Person

val billy = Student("billy", "ocean")

billy.fullName
// res3: String = "billy ocean"
{% endhighlight %}
