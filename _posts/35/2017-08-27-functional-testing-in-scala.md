---
layout: post
title:  "functional testing in scala"
date:   2017-08-27 19:11:40
categories: testing
excerpt: "testing function params in scala with scalamock"
tags:
  - scala
  - testing
---

There are so many fun things that can easily be done with Scala...this is one of the reasons I like it.

For example, here's a class with an exposed method that takes as its params an `Int`, `String` and a block of code to run which can return anything the caller wants:

{% highlight scala %}
class CoolClass {
  def doStuff[T](number: Int, word: String)(f: => T): T = {
    println(s"$number and $word")
    f
  }
}
{% endhighlight %}

Now let's make a class that depends on `CoolClass` and uses its method.

{% highlight scala %}
class ThingIWantToTest(coolClass: CoolClass) {
  def go(number: Int, word: String): Unit = {
    coolClass.doStuff(number, word)(println("WHAT IS GOING ON HERE???"))
  }
}
{% endhighlight %}

Now for some basic dependency injection in our main class:
{% highlight scala %}
object Main {
  def main(args: Array[String]) {
    val cool = new CoolClass
    val thingIWantToTest = new ThingIWantToTest(cool)
    thingIWantToTest.go(1, "hello")
  }
}
{% endhighlight %}

Here's a really easy way to test this code using the [ScalaMock](http://scalamock.org/) library.

{% highlight scala %}
import org.scalamock.scalatest.MockFactory
import org.scalatest.{FlatSpec, Matchers}

class ThingIWantToTestSpec extends FlatSpec with Matchers with MockFactory {
  val coolMock = stub[CoolClass]
  val instanceToTest = new ThingIWantToTest(coolMock)

  it should "call the coolMock method and pass in a function as an argument" in {
    instanceToTest.go(1, "hello")

    (coolMock.doStuff(_: Int, _: String)(_: Unit)).verify(*, *, *)
  }
}
{% endhighlight %}
