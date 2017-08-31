---
layout: post
title:  "efficient regex in scala"
date:   2017-08-31 07:21:04
categories: languages
excerpt: "quick overview of the best regex approach in the scala language"
tags:
  - scala
  - regular-expression
---

The super easy way to match RegEx in Scala is to use the `matches` method that is part of the string class.

> `def matches`...is added by an implicit conversion from StringOps to String.  Where needed, Strings are implicitly converted into instances of StringOps (indexed sequences)

{% highlight scala %}
val demoString = "Matchy McMatch"

val pattern = "^.*Mc.*$"
demoString.matches(pattern)

// true
{% endhighlight %}

For a more performant variety, lets consider this statement from the [Scala Docs](https://www.scala-lang.org/api/current/scala/util/matching/Regex.html):

> An instance of Regex represents a compiled regular expression pattern. Since compilation is expensive, frequently used Regexes should be constructed once, outside of loops and perhaps in a companion object.
> The canonical way to create a Regex is by using the method `r`, provided implicitly for strings

Once we construct a RegEx, strings can be tested using the standard Scala `match` expression:

{% highlight scala %}
val pattern = "^.*Mc.*$".r
demoString match {
  case pattern(_*) => true
  case _ => false
}

// true
{% endhighlight %}
