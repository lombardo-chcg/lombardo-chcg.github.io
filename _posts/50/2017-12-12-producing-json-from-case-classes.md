---
layout: post
title:  "producing json from case classes"
date:   2017-12-12 22:39:03
categories: web-programming
excerpt: "recipe for serializing a scala case class to json"
tags:
  - scala
  - json
  - json4s
  - jvm
---

[I posted previously](/web-programming/2017/10/27/scala-and-json-friends-at-last.html) about consuming JSON using the Scala [json4s](https://github.com/json4s/json4s) library.

Today I learned something new about that library when trying to produce JSON.

The situation: I want to produce json where each top-level key points to a JSON Array that was created from a `List` of `case class`es

To be specific I want to convert the following Scala:

{% highlight scala %}
case class BreakfastItem(name: String)
case class LunchItem(name: String)

val breakfastItemList = List(BreakfastItem("oj"), BreakfastItem("oatmeal"))
val lunchItemList = List(LunchItem("pbj"), LunchItem("chips"))
{% endhighlight %}

to this JSON:
{% highlight json %}
{
  "breakfast": [
    {
      "name": "oj"
    },
    {
      "name": "oatmeal"
    }
  ],
  "lunch": [
    {
      "name": "pbj"
    },
    {
      "name": "chips"
    }
  ]
}
{% endhighlight %}

(for example's sake, please imagine the case classes in use have more than just a single field...)

First..imports are important!  Esp. the `JsonDSL` one for this example.

{% highlight scala %}
import org.json4s._
import org.json4s.JsonDSL._

// and don't forget to declare this in scope of the json4s library calls:
implicit val jsonFormats: Formats = DefaultFormats
{% endhighlight %}

Using the [docs](https://github.com/json4s/json4s#producing-json), I would expect the following Scala code to produce the intended JSON using the json4s `~` operator:
{% highlight scala %}
case class BreakfastItem(name: String)
case class LunchItem(name: String)

val breakfastItemList = List(BreakfastItem("oj"), BreakfastItem("oatmeal"))
val lunchItemList = List(LunchItem("pbj"), LunchItem("chips"))

("breakfast" -> breakfastItemList) ~ ("lunch" -> lunchItemList)
{% endhighlight %}

However it fails with the following error:
{% highlight bash %}
Error:(89, 40) value ~ is not a member of (String, List[com.uptake.uptown.resources.BreakfastItem])
{% endhighlight %}

So what is going on here?  It seems the library does not know how to serialize our case class.

This can be confirmed by trying the same approach using a list of primitive strings instead of case classes:

{% highlight scala %}
("breakfast" -> List("oj", "oatmeal")) ~ ("lunch" -> List("pbj", "chips"))
{% endhighlight %}

That code checks out just fine.  So what's the fix?

The answer lies in the json4s [`Extraction`](https://github.com/json4s/json4s/blob/7da6a8458246dadb46fa7fff930823d6bf590d19/core/src/main/scala/org/json4s/Extraction.scala) object.  Its `decompose()` method will "Decompose a case class into JSON."

Usage:
{% highlight scala %}
("breakfast" -> Extraction.decompose(breakfastItemList)) ~
  ("lunch" -> Extraction.decompose(lunchItemList))
{% endhighlight %}

This will produce the intended output.
