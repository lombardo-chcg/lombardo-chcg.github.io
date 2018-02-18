---
layout: post
title:  "safety wrapper"
date:   2018-02-17 20:36:13
categories: languages
excerpt: "implementing a monadic wrapper type in scala"
tags:
  - functional
  - scala
  - monad
---

[Monads](https://en.wikipedia.org/wiki/Monad_(functional_programming)) are notoriously hard to explain, and I don't claim to know the first thing about their underlying concepts from [category theory.](https://en.wikipedia.org/wiki/Kleisli_category)

But it is a concept I want to learn more about.  I started with [this video](https://www.youtube.com/watch?v=Mw_Jnn_Y5iA) and decided to implement some of the concepts I saw.

One use case that I sorta understand is using a monad as a "wrapper" around unsafe values.  For example, values that result from making external system calls via a database connection or REST api.   Scala provides excellent native support for this approach, for example the `Either`, `Try` and `Option` types.  Wrapping unsafe operations in these types can lead to clean, readable code when used properly.

For this example let's implement a basic `Maybe` style monad.  This `Maybe` type is a wrapper around another other type, which we refer to a `A`.  Here's the interface:

{% highlight scala %}
sealed trait Maybe[A] {
  // take a regular function, return a Maybe
  def map[B](f: A => B): Maybe[B]

  // take a 'Monadic' function (function that returns a Maybe), return a Maybe
  def flatMap[B](f: A => Maybe[B]): Maybe[B]

  // Helpers
  def isEmpty: Boolean
  def getOrElse(b: Any): Any
}
{% endhighlight %}

The key methods here are `map` and `flatMap`.  Here's the difference:

`map`
* takes a regular function,
* executes the function,
* wraps the value in a Maybe and returns it
* `def map[B](f: A => B): Maybe[B] = new Maybe(f(a))`

`flatMap`
* takes a function that returns a Maybe and executes it
* `def flatMap[B](f: A => Maybe[B]): Maybe[B] = f(a)`

Our two implementations of `Maybe`:
{% highlight scala %}
case class Present[A](a: A) extends Maybe[A] {
  def map[B](f: A => B): Maybe[B] = new Present(f(a))
  def flatMap[B](f: A => Maybe[B]): Maybe[B] = f(a)
  def isEmpty = false
  def getOrElse(b: Any) = a
}

case class NotPresent[A]() extends Maybe[A] {
  def map[B](f: A => B): Maybe[B] = new NotPresent
  def flatMap[B](f: A => Maybe[B]): Maybe[B] = new NotPresent
  def isEmpty = true
  def getOrElse(b: Any) = b
}
{% endhighlight %}

The major win here is we get a stable API interface, where we can call `map` and `flatMap` all day long and not "throw" any errors and end up with a nasty user experience.  We can wrap our errors and pass them thru a computation chain and then deal with the result cleanly.

--

Let's see it in action.  First here are some stand-in operations to simulate our external calls.  

The key here is that our 2 services return objects that implement the `Maybe` API.  

{% highlight scala %}
object dbConnection {
  def performSearch(id: String): Maybe[String] = Present("Found that record in the DB")
  def simulateFailedSearch(id: String): Maybe[String] = NotPresent[String]
}

object restService {
  def makeRestCall(id: String): Maybe[String] = Present("Successful Rest Call")
  def makeAnotherRestCall(id: String): Maybe[String] = Present("Second Successful Rest Call")
  def simulateFailedRestCall(id: String): Maybe[String] = NotPresent[String]
}
{% endhighlight %}

In action (`for comprehension` style):

(as a reminder, `for comprehension`s represent calls to `flatMap` until the final statement which is a call to `map`)

{% highlight scala %}
val outcome = for {
  firstResult <- dbConnection.performSearch(id)
  secondResult <- dbConnection.simulateFailedSearch(firstResult)
  thirdResult <- dbConnection.performSearch(secondResult)
} yield thirdResult

println(outcome)
/*
* NotPresent()
*/
{% endhighlight %}

Even though the 2nd call `simulateFailedSearch` failed, the code block executes safely and yields a `NotPresent` which can be dealt with by the caller.

--

In action (function chain style):

{% highlight scala %}
val id = "some uuid"
val outcome = dbConnection.performSearch(id)
  .flatMap(restService.makeRestCall)
  .flatMap(restService.simulateFailedRestCall)
  .flatMap(restService.makeAnotherRestCall)
  .getOrElse("something went wrong")

println(outcome)
/*
* something went wrong
*/
{% endhighlight %}

Our call to `getOrElse` lets us know the function chain encountered a `NotPresent`, but still completed safely.

One more example.  Let's use the `map` function to try some regular Scala string operations, and see what happens.

{% highlight scala %}
val outcome = dbConnection.performSearch(id)
  .flatMap(restService.makeRestCall)
  .flatMap(restService.makeAnotherRestCall)
  .map(_.toUpperCase)

println(outcome)
println(outcome.isEmpty)
/*
* Present(SECOND SUCCESSFUL REST CALL)
* false
*/
{% endhighlight %}

As expected, the call to `toUpperCase` succeeded and we got our uppercase result from the REST call, wrapped in a `Maybe`.

Now let's do the same operation but with a failure in the middle:

{% highlight scala %}
val outcome = dbConnection.performSearch(id)
  .flatMap(restService.makeRestCall)
  .flatMap(restService.simulateFailedRestCall)
  .flatMap(restService.makeAnotherRestCall)
  .map(_.toUpperCase)

println(outcome)
println(outcome.isEmpty)
/*
* NotPresent()
* true
*/
{% endhighlight %}

Since calling `map` on a `Maybe` is always supported, our failure simply passes thru the call chain and pops out the bottom.  

Honestly in the case of external API calls and such, an `Either` type would be better here as the exact nature of the failure can be passed thru the function chain instead of merely a `NotPresent`.  I think of an `Either` as the same as a `Maybe` monad but with more context. 

This has been an extremely basic introduction to monads in Scala.
