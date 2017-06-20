---
layout: post
title:  "failing gracefully"
date:   2017-06-19 21:38:23
categories: languages
excerpt: "handling code that can throw errors in scala"
tags:
  - scalatra
  - scala
---

Scala provides a `util` package which provides a handy `Try` type, with its companions `Success` and `Failure`.

This reminds me very much of standard promise handling in JavaScript browser apps.

Here's a little code to try an http call (this one is destined to fail).  When it fails, the "failure" will throw a nasty exception `java.io.FileNotFoundException` with stack trace.  We can catch that error and return it as an instance of `Failure`, to be unwrapped later by some code which is ready for it.

{% highlight scala %}
import scala.util.{Try, Success, Failure}

def fetch(url: String) = scala.io.Source.fromURL(url).mkString

val url = "https://httpbin.org/hidden-basic-auth/user/passwd"

val data = Try(fetch(url)) match {
  case Success(value) => Success(value)
  case Failure(error) => Failure(error)
}

println(data)
{% endhighlight %}

From the terminal:
{% highlight bash %}
scala exception.scala
# => Failure(java.io.FileNotFoundException: https://httpbin.org/hidden-basic-auth/user/passwd)
{% endhighlight %}

And the `Failure` class has [lots of useful methods](http://www.scala-lang.org/api/2.9.3/scala/util/Failure.html) to unwrap the data.

Not saying we should always swallow stack traces...usually a bad idea.  But in some cases, it is helpful to know that an error may be coming and to handle it gracefully.
