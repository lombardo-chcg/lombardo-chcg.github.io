---
layout: post
title:  "benchmarking lookups"
date:   2017-11-22 21:53:26
categories: code-challenge
excerpt: "comparing Scala List vs. Map in massive search scenarios"
tags:
  - scala
  - performance
  - bigO
  - algorithm
---

Big O time.  Let's compare Scala's [`List`](http://www.scala-lang.org/api/2.12.3/scala/collection/immutable/List.html) to  [`Map`](http://www.scala-lang.org/api/current/scala/collection/Map.html) for doing searches.

The `List` doc lays it out pretty clearly:

> List has O(1) prepend and head/tail access. Most other operations are O(n) on the number of elements in the list.

So searching a list will take O(n) worst-case, aka "Linear Lookup"

Our `Map`, meanwhile, is a lookup table, which provides O(1) aka "Constant Time Lookup"

So what's that mean in the real world?  Let's put some metrics on it to give meaning to the fancy words.

Here's the benchmark setup:

* create a `primeList` containing all numbers under 10,000,000 using my [Sieve of Eratosthenes](/code-challenge/2017/10/09/sieve-of-eratosthenes.html)
* create a map with an entry of `Int -> Boolean` for each prime in the `primeList`

benchmark overview:

* lookup 10,000 random numbers in the map to see if they are prime
* lookup 10,000 random numbers in the list to see if they are prime

benchmark impl:

{% highlight scala %}
class Benchmark {
  val pc = new PrimeCalculator
  val primeList = pc.primesUnder(10000000)
  val primeMap = pc.primeMap(primeList)
  val r = scala.util.Random

  def executeMap: Unit = {
    time("Map") {
      for (i <- 1 to 10000) yield {
        primeMap.contains(r.nextInt(10000000))
      }
    }
  }

  def executeList: Unit = {
    time("List") {
      for (i <- 1 to 10000) yield {
        primeList.contains(r.nextInt(10000000))
      }
    }
  }
}
{% endhighlight %}

So...the moment of truth.  What does `O(n)` vs. `O(1)` look like in the real world??

* Map - elapsed time 8 ms
* List - elapsed time 30816 ms

Results speak for themselves, and speak to the fact that it pays to think about data structures and the needs of the program using them.
