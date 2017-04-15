---
layout: post
title:  "scala sequence comprehensions"
date:   2017-04-14 19:41:24
categories: languages
excerpt: "using for/yield expressions in scala to handle collection transformations"
tags:
  - scala
  - functional
---

As part of my [Scalatra-Docker-Postgres](/search?term=scalatra) series, I am making an API endpoint that accepts a group of characters, and returns a collection of all valid Scrabble words that can be constructed from that group, along with their raw point values.

This means I need a function that takes a collection of letters and find all possible subset combinations.  For example, given the word "dog", I need the function to return `d, o, g, do, dg, go, dgo`

Notice that no combination is repeated, and that combinations are also in alphabetical (canonical) order.  Having the subsets in canonical format is the key for using the SQL table for lookup.

With Scala's built-in `List` class we have all we need to make this happen.  The key is the `combinations` method that we get for free with an instance of `List`.  [Read more here](https://www.scala-lang.org/api/current/scala/collection/immutable/List.html)

One way to accomplish this task it go pure functional, using `flatMap` and `map` to create a data pipeline which produces the result we need.   Here's that implementation:

{% highlight scala %}
val word = "dog"

// break up the string into a iterable
val charList = word.split("").toList
// create a range that represents all possible subset lengths
(1 to charList.length)  
// create an indexed sequence of all unique letter combinations at each length in the range
.flatMap(num => charList.combinations(num))
// map each letter combination into an alphabetically sorted string
.map(chars => chars.sorted.mkString)
// convert to list for a clean data interface
.toList

// List[String] = List(d, o, g, do, dg, go, dgo)
{% endhighlight %}

This sequence is not hard to read.  But imagine adding a few more levels of processing before we arrive to the final `map` which produces the output.  We'd be looking at a long chain of functions which may look sexy but lack clarity.

Now let's consider an alternative construct to create this function.  This construct is known as many names in Scalaland:

* sequence comprehension
* for expression
* for comprehension
* for/yield loop

Is this easier to read?

{% highlight scala %}
val word = "dog"
val charList = word.split("").toList

val charList = word.split("").toList

val output = for {
  length <- 1 to charList.length
  combo <- charList.combinations(length)
} yield combo.sorted.mkString
{% endhighlight %}

Each `<-` in the sequence above is a `generator` which calls `flatMap`, `filter` or `map` and produces a new collection.  The final `generator` yields each element in the final resulting collection to a code block (i.e. a `map` function) where the final transformations occur.

In the end its up to personal style.  I personally prefer the function chain style.  But in the terse land of Scala, easily readable can be a rare treat.
