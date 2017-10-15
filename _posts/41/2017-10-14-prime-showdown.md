---
layout: post
title:  "prime showdown"
date:   2017-10-14 16:10:43
categories: code-challenge
excerpt: "performance testing Sieve of Eratosthenes vs. trial division when finding the nth prime in scala"
tags:
- algorithm
- prime
- euler
---

Testing the [code I posted yesterday](/code-challenge/2017/10/13/nth-prime.html) against a basic, iterative trial division brute force prime checker.

It's not even close...

{% highlight bash %}
let n = 1,000,000

# Return the nth prime number via Sieve of Eratosthenes
elapsed time: 856 ms

# Return the nth prime number via trial division
elapsed time: 458430 ms == 458.43 seconds == 7.6405 minutes
{% endhighlight %}
