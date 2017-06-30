---
layout: post
title:  "scala xerox machine"
date:   2017-06-30 07:04:48
categories: languages
excerpt: "working with immutable data structures in scala"
tags:
  - scalatra
  - scala
---

Scala case classes are a great language feature that allows a developer to create and pass strongly typed, immutable objects around an application.   I look at them as containers for elements that are logically grouped together under an umbrella concept.  They are similar to the `DTO` in that they usually don't contain any methods or logic.

Case class instances also come with a handy method called `copy` which is the functional solution for "changing" the values of a case class.  Instead of reassigning existing fields, the Scala solution is to copy the object and specify new values as arguments.

Lets specify some leftovers being eaten at a different time using the copy method:
{% highlight scala %}
case class Dinner(sides: List[String], mainCourse: String, time: String)

val mondayNight = Dinner(List("broccoli", "potatoes"), "Pork", "7:00pm")

val tuesdayNight = mondayNight.copy(time = "8:30pm")
{% endhighlight %}

[Here are some deep notes on case classes from scala-lang.org](https://www.scala-lang.org/files/archive/spec/2.11/05-classes-and-objects.html#case-classes)
