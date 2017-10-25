---
layout: post
title:  "coming soon to java.lang"
date:   2017-10-24 21:50:56
categories: teachers
excerpt: "preview of new java features from Brian Goetz of Oracle"
tags:
  - jvm
  - java
  - scala
---

Last night I attended a meetup of the Chicago Java User’s Group where I got to hear a talk by Brian Goetz,  Java Language Architect at Oracle.  Here are some exciting tidbits that he shared:

* Java is planning to go to a twice a year release cadence, in March and October.  This will allow smaller features to get into developers' hands more quicker instead of "sitting in a repo gathering dust" as Brian said.  Java 10 will be released in March 2018.
* the intro of the `var` keyword and [Local-Variable Type Inference](http://openjdk.java.net/jeps/286)
* the introduction of a "data class" which is similar to the Scala case class, inspiried by algebraic data types
* the upgrade of `switch` from a statement to an expression (aka has a return value)
* new `switch` will incorporate pattern matching, just like Scala's `match`.  This means it goes from O(n) linear time on a `switch` statement, to `o(1)` hash-table performance while pattern matching.
* new `switch` will also do "deconstruction" which is `unapply` in Scala.  Basically, match an object against a pattern, extract a value from the object, and bind the value to a new local variable.
* it also seemed like the famous Scala "that sign that means that thing over there", `_`, will be making an appearance in the new `switch`


--

TL;DR - Java is going to be incorporating some of the best parts of the Scala language (`case class`, `match`) in upcoming releases.
