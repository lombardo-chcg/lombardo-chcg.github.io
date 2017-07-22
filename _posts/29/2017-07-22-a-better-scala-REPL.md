---
layout: post
title:  "a better scala REPL"
date:   2017-07-22 08:06:14
categories: tools
excerpt: "getting more power at the command line from the Ammonite project"
tags:
  - terminal
  - bash
  - scala
---

The out-of-the-box Scala REPL is useful for getting familiar with the language's built-in libraries.

However it lacks some key components.  For example, I like to use the REPL to experiment with new 3rd party libraries and test drive them.  Ruby's `irb` REPL allows this easily with any Gem library.  For example `require 'nokogiri'` is all it takes to load up a Gem.

Scala's built-in REPL lacks this feature.  Which is why I was excited to discover the [Ammonite project](http://ammonite.io/#Ammonite).  Today I will explore the enhanced REPL of the Ammonite project.

[*Installation instructions*](http://ammonite.io/#Ammonite-REPL)


Ammonite allows the user to bring in [Ivy packages](http://ant.apache.org/ivy/m2comparison.html) which gives us access to a vast world of Java and Scala packages.   Let's use the famous Joda Time as a quick example.

{% highlight scala %}
import $ivy.`joda-time:joda-time:2.9.9`
{% endhighlight %}

2 quick notes
* the backticks seen in the command above is the Scala way to give a variable an otherwise illegal name.  Using `.` symbols is usually the way to access class values or methods, not name a variable.  With the backticks we get around that restriction.
* The Ivy dependency format was taken from [mvnrepository.com](https://mvnrepository.com/artifact/joda-time/joda-time/2.9.9) in the format of `org:name:rev`

Now we can use the library as we would in any normal Scala file:

{% highlight scala %}
import org.joda.time._

val now = new DateTime

now.minusSeconds(30)
{% endhighlight %}

Cool syntax highlighting, right??

This nifty leaves the door open for lots of fun experimentation while learning a new Scala or Java library.

Yes I know this "extended REPL" feature is available via SBT, but I find this easier as I don't have to add dependencies to an SBT file and then compile.  This is better for quick POC on a new library. 
