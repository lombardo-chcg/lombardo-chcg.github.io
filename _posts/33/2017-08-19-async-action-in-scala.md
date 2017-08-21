---
layout: post
title:  "async action in scala"
date:   2017-08-19 23:08:23
categories: languages
excerpt: "a quick example of parallel code in scala"
tags:
  - scala
  - future
  - promise
---

Turns out Scala has a pretty badass native library for handling asynchronous data handling.

A quick use case:
* we have an HTTP server, and want to log all the requests being made to it (say we're writing each request to a DB)
* however performance is important and we don't want to take a hit for the log I/O
* so we need a way to dispatch a log message creation request without having to wait for it to finish.

Scala `Future` can help us out.  From the [docs](https://docs.scala-lang.org/overviews/core/futures.html):

> A Future is a placeholder object for a value that may not yet exist.

`example.scala`
{% highlight scala %}
import scala.concurrent.{Future}
import scala.concurrent.ExecutionContext.Implicits.global // note: more on implicits soon!

def asyncLogAction(msg: String): Future[Unit] = {
  Future {
    Thread.sleep(1000)
    println(msg)
  }
}

def handleRequest(): Unit = {
  println("request received")
  println("doing some stuff here to handle the request")
  asyncLogAction("request logged")
  println("done, returning json response body")
}

handleRequest()
Thread.sleep(5000)
{% endhighlight %}

{% highlight bash %}
scala example.scala

# request received
# doing some stuff here to handle the request
# done, returning json response body
# request logged
{% endhighlight %}

So this is a heavy handed sample, but it shows that the hot path `handleRequest` executed without waiting for the `asyncLogAction` to complete.  

Now let's edit the code slightly to make it "blocking" by calling `Await` on our method that is returning the future:
{% highlight scala %}
import scala.concurrent.{Await, Future}
import scala.concurrent.ExecutionContext.Implicits.global // note: more on implicits soon!
import scala.concurrent.duration._
import scala.language.postfixOps

def asyncLogAction(msg: String): Future[Unit] = {
  Future {
    Thread.sleep(1000)
    println(msg)
  }
}

def handleRequest(): Unit = {
  println("request received")
  println("doing some stuff here to handle the request")
  Await.result(asyncLogAction("request logged"), 2 seconds)
  println("done, returning json response body")
}

handleRequest()
Thread.sleep(5000)
{% endhighlight %}

Now when we run the code again, it executes in "order" as we are forcing the execution to wait on the future to be resolved.  

{% highlight bash %}
# request received
# doing some stuff here to handle the request
# request logged
# done, returning json response body
{% endhighlight %}
