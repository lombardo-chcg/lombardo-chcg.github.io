---
layout: post
title:  "scala type classes for the confused"
date:   2018-07-04 12:42:11
categories: languages
excerpt: "explain and implement a type class example in a straightforward manner"
tags:
  - scala
  - functional
  - type
---

When I started reading about type classes in Scala, I quickly became confused by available resources.  This post was an exercise in getting to clarity.

### Post Purposes
- explain type classes in a straightforward way
- build a concrete, basic example

### What is a type class?

Let's begin by ditching the common understanding of `class` as it is used in object-oriented design (i.e. a template that is used to instantiate objects).  For this example, let's think about classes as a more general concept:

> *class: a group of things that share attributes.*

The `type class` concept first appeared in Haskell, which is a totally functional programming language.  Haskell does not have the concept of objects and classes as we understand them in object-oriented languages like Scala.  Regarding the term's Haskell roots, I found this definition to be most illuminating:

> A typeclass is a sort of interface that defines some behavior. If a type is a part of a typeclass, that means that it supports and implements the behavior the typeclass describes.

> source: [http://learnyouahaskell.com/types-and-typeclasses](http://learnyouahaskell.com/types-and-typeclasses)

To me it seems type classes were introduced in Haskell as a way to offer the same behavior that Java `interface`s and Scala `trait`s offer:  make sure a given type honors a defined contract BEFORE code can be successfully compiled.

--

So why not just use standard inheritance patterns in Scala?  What is the purpose of introducing this type class concept?

In Scala, type classes provide the programmer a way to extend the behavior of existing types WITHOUT modifying the code for those types.  This is achieved thru the use of Scala's signature feature: `implicit`s.  

It comes in handy for adding new behavior to 3rd party types, such as extending a standard library class.

For example, let's say we have a need to represent a given base-10 number in a "padded" binary form.  We want the binary representation's length to be a multiple of 8.  

Here's the native `toBinaryString` method which exists on the `Int` class:
{% highlight scala %}
8.toBinaryString
// res18: String = "1000"
{% endhighlight %}

The length of the binary string representation, `1000`, is 4.  Instead, we want the output to be `00001000` since this is the next multiple of 8.

So we can introduce a extension method to the Scala `Int` class called `toPaddedBinaryString` which fills our needs.

However, we also want this same behavior on `Long`s and `BigInt`s.  

In other words, we want these 3 built-in types to support and implement the same basic behavior which is not provided in the standard library.

Since we didn't write the code for these Scala numeric classes, we need to find a way to extend their functionality.  This is where the type class pattern fits in.

### Rubber, meet road

In a non-abstract sense, what is a type class in Scala?

> A type class in Scala is a trait with at least 1 type variable.

> source: [https://underscore.io/books/essential-scala/](https://underscore.io/books/essential-scala/)

Oh.  that's not so bad!  So we just need to define a trait using a generic type, which defines the contract that all concrete classes must honor.

--
##### **STEP ONE: DEFINE A TRAIT**

{% highlight scala %}
trait BinaryStringPadder[A] {
  def toPaddedBinaryString(n: A): String
}
{% endhighlight %}

Any type that implements this trait is a member of the type class.

So let's create instances of the type class for each involved type: `Int`, `Long` and `BigInt`

--

##### **STEP TWO: CREATE INSTANCES OF THE TYPE CLASS FOR EACH USE CASE**  
{% highlight scala %}
object BinaryStringPadderImplicits {
  implicit object IntPadder extends BinaryStringPadder[Int] {
    def toPaddedBinaryString(n: Int): String = {
      val s = n.toBinaryString
      pad(s)
    }
  }

  implicit object LongPadder extends BinaryStringPadder[Long] {
    def toPaddedBinaryString(n: Long): String = {
      val s = n.toBinaryString
      pad(s)
    }
  }

  implicit object BigIntPadder extends BinaryStringPadder[BigInt] {
    def toPaddedBinaryString(n: BigInt): String = {
       val s = n.toString(2)
       pad(s)
    }
  }

  // shared padding logic
  private def pad(s: String): String = {
    if (s.length % 8 == 0) s
    else {
      val paddingSize = (((s.length / 8) * 8) + 8) - s.length
      (1 to paddingSize).map(_ => "0").mkString + s
    }
  }
}
{% endhighlight %}

--

##### **STEP THREE: EXPOSE AN INTERFACE VIA AN IMPLICIT CLASS**

An implicit class is another nifty Scala feature which,

> makes the class’s primary constructor available for implicit conversions when the class is in scope.

> Source: [https://docs.scala-lang.org/overviews/core/implicit-classes.html](https://docs.scala-lang.org/overviews/core/implicit-classes.html)

In other words, when the complier finds a method call on an object which is not defined on that object, the compiler will search the implicit scope for a class which takes the object as a constructor param and contains the defined method.  The compiler will then call the implicit class's constructor and continue on its merry way.

{% highlight scala %}
object BinaryStringPadder {
  implicit class PadsBinaryStrings[A](n: A) {
    def toPaddedBinaryString(implicit padder: BinaryStringPadder[A]): String = {
      padder.toPaddedBinaryString(n)
    }
  }
}
{% endhighlight %}

--

To use:

- import the `BinaryStringPadder` implicit class
- `BinaryStringPadder` has an implicit param, a `BinaryStringPadder` of the type in use
- thus import the `BinaryStringPadder` for the type in use so it is available in the implicit scope


{% highlight scala %}
import BinaryStringPadderImplicits._
import BinaryStringPadder._

assert(11.toPaddedBinaryString == "00001011")
assert(45867L.toPaddedBinaryString == "1011001100101011")
assert(BigInt(86543248).toPaddedBinaryString == "00000101001010001000101110010000")
{% endhighlight %}


--

*full example:*

{% highlight scala %}
trait BinaryStringPadder[A] {
  def toPaddedBinaryString(n: A): String
}

object BinaryStringPadderImplicits {
  implicit object IntPadder extends BinaryStringPadder[Int] {
    def toPaddedBinaryString(n: Int): String = {
      val s = n.toBinaryString
      pad(s)
    }
  }

  implicit object LongPadder extends BinaryStringPadder[Long] {
    def toPaddedBinaryString(n: Long): String = {
      val s = n.toBinaryString
      pad(s)
    }
  }

  implicit object BigIntPadder extends BinaryStringPadder[BigInt] {
    def toPaddedBinaryString(n: BigInt): String = {
       val s = n.toString(2)
       pad(s)
    }
  }

  private def pad(s: String): String = {
    if (s.length % 8 == 0) s
    else {
      val paddingSize = (((s.length / 8) * 8) + 8) - s.length
      (1 to paddingSize).map(_ => "0").mkString + s
    }
  }
}

object BinaryStringPadder {
  implicit class PadsBinaryStrings[A](n: A) {
    def toPaddedBinaryString(implicit padder: BinaryStringPadder[A]): String = {
      padder.toPaddedBinaryString(n)
    }
  }
}

import BinaryStringPadderImplicits._
import BinaryStringPadder._

assert(11.toPaddedBinaryString == "00001011")
assert(45867L.toPaddedBinaryString == "1011001100101011")
assert(BigInt(86543248).toPaddedBinaryString == "00000101001010001000101110010000")
{% endhighlight %}
