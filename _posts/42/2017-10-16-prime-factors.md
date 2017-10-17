---
layout: post
title:  "prime factors"
date:   2017-10-16 21:04:52
categories: numbers
excerpt: "the periodic table of numbers"
tags:
- algorithm
- prime
- euler
---

The [Fundamental theorem of arithmetic](https://en.wikipedia.org/wiki/Fundamental_theorem_of_arithmetic) is nothing new but super interesting.  It states that every non-prime number is the product of a unique combination of prime numbers, meaning that primes are the "building blocks" for all numbers.  Reminds me of the periodic table of the elements.

Here's a way to find the unique prime factorization for any number:
* start by finding the first prime factor for the given number.  Put that number into a new `List`
* divide, and call the function again on the result, appending the result to the list
* recurse until it hits the base case - a result of 1 - indicating that we have reduced the original number down to a prime.  
* The resulting list is the prime factorization of that number

example: prime factors of 123123123

| **Starting Number** | **Lowest Prime Factor** | **Result of Division** | **Prime Factors List** |
| 123123123 | 3  | 41041041 | `List(3)` |
| 41041041  | 3  | 13680347 | `List(3, 3)` |
| 13680347 | 41  | 333667 | `List(3, 3, 41)` |
| 333667 | 333667  | 1 | `List(3, 3, 41, 333667)` |

Since the result of the last division is 1, which is our base case, the recursion stops and all the calls return with our answer.


Since it is a recursive function that relies on having a list of existing primes, I decided to pass the list to the function call instead of recalculating it for every iteration.  A good way to get some milage from a [prime number sieve](/code-challenge/2017/10/09/sieve-of-eratosthenes.html)!

{% highlight scala %}
// @param primeList: List[Int] is the output of a prime number sieve to n
def primeFactors(n: Int, primeList: List[Int]): List[Int] = {
  if (n <= 1) List()
  else {
    val firstPrimeFactor = primeList.view.find(n % _ == 0) match {
      case Some(i) => i
      case _ => throw new Exception("something went wrong, check your primeList input?")
    }
    List(firstPrimeFactor) ++ primeFactors(n / firstPrimeFactor, primeList)
  }
}
{% endhighlight %}

test suite:
{% highlight scala %}
it should "find prime factors" in {
  val pc = new PrimeCalculator
  val genericPrimeList = pc.primesUnder(1000)
  pc.primeFactors(6, genericPrimeList) should be(List(2, 3))
  pc.primeFactors(8, genericPrimeList) should be(List(2, 2, 2))
  pc.primeFactors(14, genericPrimeList) should be(List(2, 7))
  pc.primeFactors(15, genericPrimeList) should be(List(3, 5))
  pc.primeFactors(644, genericPrimeList) should be(List(2, 2, 7, 23))
  pc.primeFactors(645, genericPrimeList) should be(List(3, 5, 43))
  pc.primeFactors(646, genericPrimeList) should be(List(2, 17, 19))

  pc.primeFactors(123123123, pc.primesUnder(123123123)) should be(List(3,3,41,333667))
}
{% endhighlight %}

My [prime calculator scala code](https://github.com/lombardo-chcg/functional_euler/blob/master/src/main/scala/com/lombardo/app/helpers/PrimeCalculator.scala) for reference

<style>
table {
    border-collapse: collapse;
    border-spacing: 0;
    border:2px solid #000000;
}

th {
    border:2px solid #000000;
    padding: 5px;
}

td {
    border:1px solid #000000;
    padding: 5px;
    font-size: 14px;
}
</style>
