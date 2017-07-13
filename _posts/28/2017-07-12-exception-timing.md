---
layout: post
title:  "exception timing"
date:   2017-07-12 21:11:42
categories: performance
excerpt: "measuring the cost of throwing exceptions in on the jvm"
tags:
  - scala
---

Today a quick experiment to examine different ways to handle errors in Scala.  I'll be doing this all in the `scala` REPL.

First, lets define a timer method that takes a function as an argument and runs it 1,000 times, then prints the elapsed time in ms:

{% highlight scala %}
import scala.util.{Try, Success, Failure}

def opTimer[T](operation: => T): Unit = {
  val startTime = System.currentTimeMillis

  for (i <- 1 until 1000) {
    Try(operation) match {
      case Success(x) => x
      case Failure(ex) => ex
    }    
  }

  val endTime = System.currentTimeMillis

  println(s"""elapsed time ${endTime - startTime } ms""")
}
{% endhighlight %}

Next we'll define a "safe" function that returns an `Int`, a function that returns a `case class`, and finally a function that throws an `Exception`:

{% highlight scala %}

def returnInt: Int = 50 + 50

case class Dinner(sides: List[String], mainCourse: String, time: String)
def returnCaseClass: Dinner = Dinner(List("broccoli", "potatoes"), "Pork", "7:00pm")

def throwException: Unit = throw new Exception("bad news bears")

{% endhighlight %}

Now let's run them thru the timer:

{% highlight scala %}
opTimer(returnInt)
// elapsed time 2 ms

opTimer(returnCaseClass)
// elapsed time 5 ms

opTimer(throwException)
// elapsed time 10 ms
{% endhighlight %}

The results are not too surprising.  We can see that when an "error" case is needed in a decision tree, it is much more cost effective to return a custom "Error wrapper" case class with details than it is to throw an exception.  In fact it performs twice as fast.  It pays to think about error handling and performance. 
