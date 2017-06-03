---
layout: post
title:  "zipping case classes in scala"
date:   2017-06-03 14:24:09
categories: languages
excerpt: "converting a case class to a Map in scala"
tags:
  - scala
---

Let's say we have a Scala method that takes an input param of `Map[String, Any]`, where `String` is a DB column name and `Any` is the value.

However the data we need to insert into the DB is in the format of a Scala case class.

How do we convert the case class to a Map for DB insertion?

First let's compare the input and output:


Existing data structure:
{% highlight scala %}
case class LogMessage(date: String, event: String, elapsedTimeMs: Int)
{% endhighlight %}

What our DB service requires:
{% highlight scala %}
val dbMsg = Map("date" -> "June 3", "event" -> "User Logged In", "elapsedTimeMs" -> 13)
{% endhighlight %}

So let's do the conversion.

Since Scala case classes extend the [`Product` trait](http://www.scala-lang.org/api/2.12.1/scala/Product.html), our method signature will accept a Product, and depend on its `productIterator` implementation.

{% highlight scala %}
private def caseClassToMap(obj: Product): Map[String, Any] = {

}
{% endhighlight %}

To obtain the "keys" for our map, we will use some standard Java reflection methods:

{% highlight scala %}
private def caseClassToMap(obj: Product): Map[String, Any] = {
  val keys = obj.getClass.getDeclaredFields.map(_.getName).toList
}
{% endhighlight %}

To obtain the "values" for our map, we will use the `productIterator` method that our class class implements based on it extending the `Product` trait:

{% highlight scala %}
private def caseClassToMap(obj: Product): Map[String, Any] = {
  val keys = obj.getClass.getDeclaredFields.map(_.getName).toList
  val values = obj.productIterator.toList
}
{% endhighlight %}

Now we have extracted our values, we need to `zip` them together into a map.

{% highlight scala %}
private def caseClassToMap(obj: Product): Map[String, Any] = {
  val keys = obj.getClass.getDeclaredFields.map(_.getName).toList
  val values = obj.productIterator.toList

  keys.zip(values).toMap
}
{% endhighlight %}

Now we can perform the conversion.

{% highlight scala %}
case class LogMessage(date: String, event: String, elapsedTimeMs: Int)

val msg = LogMessage("June 3", "User Logged In", 13)

caseClassToMap(msg)
//=> Map[String,Any] = Map(date -> June 3, event -> User Logged In, elapsedTimeMs -> 13)
{% endhighlight %}
