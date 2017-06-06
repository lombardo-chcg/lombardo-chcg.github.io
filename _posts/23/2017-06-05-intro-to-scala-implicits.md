---
layout: post
title:  "intro to scala implicits"
date:   2017-06-05 22:15:01
categories: languages
excerpt: "enhancing an existing trait with implicits"
tags:
  - scala
---

Implicits get a bad rep in Scala.  The wisdom goes: "Implicits are great, unless someone else wrote them."  Their reputation is that of convenience at the cost of readability.

But I'm curious about their mysterious power so I thought I'd try a concrete example.

[My last post](/languages/2017/06/03/zipping-collections-in-scala.html) about converting a Case Class to a Map is a perfect example of where implicits can shine.

Our end goal is to be able to call this method on any case class, and get a map:

{% highlight scala %}
myCaseClass.toMap
{% endhighlight %}

Implicits can be defined thru the `implicit class` keyword.  [There are some basic restrictions](http://docs.scala-lang.org/overviews/core/implicit-classes.html) on implicit classes, so to adhere we can place our definition inside a util object.

Inside our object, we simply define our implicit class and its method(s).  You'll notice the syntax of the method is very similar to the `def` from the [previous example](/languages/2017/06/03/zipping-collections-in-scala.html)

{% highlight scala %}
package com.lombardo.app.utils

import org.slf4j.LoggerFactory

object ApiUtils {

  implicit class ProductMapper(val obj: Product) {

    def toMap = {
      val keys = obj.getClass.getDeclaredFields.map(_.getName).toList
      val values = obj.productIterator.toList

      keys.zip(values).toMap
    }
  }
}
{% endhighlight %}

Now to use, we just import the utils object and call `toMap` on our case class instance directly.  In this case, we are recording a `ServerLog` event using a repository service.  Our repository service requires a `Map` as its input, and our implicit class makes the conversion from case class to map nice and clear:

{% highlight scala %}
import com.lombardo.app.utils.ApiUtils._

case class ServerEvent(userRequest: String, userAgent: String, elapsedTimeMs: Long)

class LoggerService {

  def logEvent(event: ServerEvent): Option[Int] = {

    repositoryService.insert(event.toMap)
  }
}
{% endhighlight %}
