---
layout: post
title:  "fake data for the jvm"
date:   2017-12-04 21:27:14
categories: tools
excerpt: "using jFairy to generate data for a scala project"
tags:
  - jvm
  - faker
  -
---


[`Faker`](https://github.com/stympy/faker) is a great library for generating fake data inside a Ruby project.  A common use case is for creating test data to stick into a database for development purposes or data for unit tests.

[`jFairy`](https://github.com/Devskiller/jfairy) is a quick way to do this in a JVM project.  Here's a quick Scala [`Ammonite`](http://ammonite.io/#Ammonite-REPL) REPL session showing how it works.

{% highlight scala %}
Welcome to the Ammonite Repl 1.0.2

import $ivy.`io.codearte.jfairy:jfairy:0.5.9`

import io.codearte.jfairy._

val tp = Fairy.create().textProducer()

tp.word(1)
tp.word(15)
tp.sentence
tp.paragraph
tp.loremIpsum

val p = Fairy.create().person()
// can then get address, age, email, name, username, etc...

val cc = Fairy.create().creditCard()

val np = Fairy.create().networkProducer()
np.ipAddress

val dp = Fairy.create().dateProducer()
dp.randomDateInThePast(5)
dp.randomDateInTheFuture(1000)
{% endhighlight %}
