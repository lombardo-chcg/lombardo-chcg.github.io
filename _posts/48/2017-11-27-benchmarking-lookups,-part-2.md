---
layout: post
title:  "benchmarking lookups, part 2"
date:   2017-11-27 22:21:53
categories: code-challenge
excerpt: "adding a binary search algorithm to the massive search scenario"
tags:
  - scala
  - performance
  - bigO
  - algorithm
  - recursive
  - binary
---

[A few days ago](/code-challenge/2017/11/22/benchmarking-lookups.html) I compared search performance of a Linked List vs. a Hashmap.

Let's add an Indexed List to the mix and see how it goes.

How is an indexed list different from a linked list?

As a quick refreshed: a linked list is a data structure where list elements can live anywhere in the system memory.  Each item in the list contains a pointer to the next item's memory location.  Therefore, to check and see if an item is in the list, we have to Iterate thru each list item (in the worst case) and check to see if it is the item we seek.  Or if the user requests the item at list position `n`, all the items prior to `n` in the list must be scanned first.  Therefore this is an `O(n)` algorithm.

An indexed list (aka, an Array) contains items that are "indexed" in memory.  Meaning, the system knows how to find each item based on its index position, and doesn't need to iterate thru the list until it finds the target.

So let's see how they compare in a massive search situation.

[*be sure to read the previous post to find out about what we are searching for*](/code-challenge/2017/11/22/benchmarking-lookups.html)

First, here's a basic Binary Search algorithm in Scala.  The method is to basically move the "high" or "low" pointers around depending on if the middle-indexed element is higher or lower than the target.  Instead of using a while loop the search function just calls itself recursively, and uses a wrapper function to properly format the data before the recursion starts.  I don't know if this is a good or established pattern but it works for my needs (the wrapper function I mean).

{% highlight scala %}
class BinarySearcher {
  def getIndexOf(list: Array[Int], targetItem: Int): Int = {
    val lowIndex = 0
    val highIndex = list.size - 1
    doGetIndex(list, targetItem, lowIndex, highIndex)
  }

  private def doGetIndex(list: Array[Int], targetItem: Int, lowIndex: Int, highIndex: Int): Int = {
    val middleIndex = (lowIndex + highIndex) / 2
    val guess = list(middleIndex)
    if (guess == targetItem) middleIndex
    else if (lowIndex > highIndex) -1  // this case means the target is not in the array
    else if (guess > targetItem) doGetIndex(list, targetItem, lowIndex, middleIndex - 1)
    else doGetIndex(list, targetItem, middleIndex + 1, highIndex)
  }
}  
{% endhighlight %}


expanding our Benchmark:

{% highlight scala %}
class Benchmark {
  val pc = new PrimeCalculator
  val bs = new BinarySearcher
  val primeList = pc.primesUnder(10000000)
  val primeArray = primeList.toArray
  val primeMap = pc.primeMap(primeList)
  val r = scala.util.Random

  def executeMap: Unit = {
    time("Map") {
      for (i <- 1 to 10000) yield {
        primeMap.contains(r.nextInt(10000000))
      }
    }
  }

  def executeBinarySearch: Unit = {
    time("Binary Search") {
      for (i <- 1 to 10000) yield {
        bs.getIndexOf(primeArray, r.nextInt(10000000))
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

Results:
* Map - elapsed time 8 ms - `O(1)`
* Binary Search - elapsed time 12 ms - `O(log n)`
* Linked List - List - elapsed time 29692 ms - `O(n)`

Binary Search is blazing fast!  This is a cool, real-world example of the performance difference between `Constant Time`, `Logarithmic Time`, and `Linear Time`
