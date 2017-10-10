---
layout: post
title:  "prime number sieve in scala"
date:   2017-10-09 21:50:31
categories: code-challenge
excerpt: "imperative implementation the ancient Sieve of Eratosthenes in scala"
tags:
  - algorithm
  - prime
  - euler
---

Here's a basic imperative-style implementation of the Sieve of Eratosthenes in Scala.

I made it by following the [Pseudocode](https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes#Pseudocode) as seen on Wikipedia.

TODO: report back a performance comparison between this solution and the more basic "trial division" method for finding prime numbers.

{% highlight scala %}
import scala.collection.mutable.ArrayBuffer

class PrimeCalculator {
  def primesUnder(n: Int): List[Int] = {
    // Input: an integer n > 1.
    if (n <= 1) List()
    else {
      // Let A be an array of Boolean values, indexed by integers 2 to n, initially all set to true.
      val A = ArrayBuffer.fill(n + 1)(true)
      // for i = 2, 3, 4, ..., not exceeding √n: if A[i] is true:
      for (i <- 2 to Math.sqrt(n).toInt if A(i)) {
        // for j = i2, i2+i, i2+2i, i2+3i, ..., not exceeding n:
        for (j <- (i * i) to n by i) {
          // A[j] := false.
          A.update(j, false)
        }
      }

      // Output: all i such that A[i] is true.
      (for (m <- A.indices if A(m)) yield m)
        .drop(2)  // handling the 'off by 2' problem of the 0th index'ed array
        .takeWhile(_ < n)  
        .toList
    }
  }
}
{% endhighlight %}

Test Suite:
{% highlight scala %}
import org.scalatest.{FlatSpec, Matchers}

class PrimeCalculatorTest extends FlatSpec with Matchers {
  val primeCalculator = new PrimeCalculator

  it should "return a list of all primes under a given number" in {
    val expected30 = List(2, 3, 5, 7, 11, 13, 17, 19, 23, 29)
    val expected100 = List(2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97)
    val expected1000 = List(2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431, 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509, 521, 523, 541, 547, 557, 563, 569, 571, 577, 587, 593, 599, 601, 607, 613, 617, 619, 631, 641, 643, 647, 653, 659, 661, 673, 677, 683, 691, 701, 709, 719, 727, 733, 739, 743, 751, 757, 761, 769, 773, 787, 797, 809, 811, 821, 823, 827, 829, 839, 853, 857, 859, 863, 877, 881, 883, 887, 907, 911, 919, 929, 937, 941, 947, 953, 967, 971, 977, 983, 991, 997)
    val primeCalculator = new PrimeCalculator
    primeCalculator.primesUnder(1) should equal(List())
    primeCalculator.primesUnder(2) should equal(List())
    primeCalculator.primesUnder(3) should equal(List(2))
    primeCalculator.primesUnder(4) should equal(List(2, 3))
    primeCalculator.primesUnder(30) should equal(expected30)
    primeCalculator.primesUnder(100) should equal(expected100)
    primeCalculator.primesUnder(1000) should equal(expected1000)
  }
}

{% endhighlight %}
