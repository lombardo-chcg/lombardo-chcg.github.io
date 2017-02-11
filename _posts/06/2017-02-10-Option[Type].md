---
layout: post
title:  "Option[Type]"
date:   2017-02-10 20:59:13
categories: languages
excerpt: "wrapping possible null values with Scala"
tags:
  - scala
  - javascript
  - functional-programming
---

Today while debugging some backend Scala code I came across a function that returned an `Option`.  I was intrigued and did some digging.  It turns out the option class is basically a safe wrapper around a possibly unsafe value.

Scala has the concept of a `Some` or a `None` object, and an option represents a value that may be `Some` or `None`.

For example:
{% highlight scala %}
val goodBool: Option[Boolean] = Some(true)

val badBool: Option[Boolean] = Some(false)

val evilBool: Option[Boolean] = None
{% endhighlight %}

"So what's the point?" you may say to yourself.  "Why not just true or false?" Like much of Scala it seems overly complex at first.  After thinking about it, this concept makes a lot of sense.  For one, an Option makes the code readable.  The person consuming the function that returns an Option knows instantly that the function can possibly return a null value and can plan accordingly.  For example, they could use the `getOrElse` method on the option to get the value, or else provide a default.

Secondly, it seems native Scala functions like `map` and `filter` can also handle Options without exploding.

Coming from a JavaScript background, the concept of a `map` function not self-destructing over a null value is mind boggling.  Having a `undefined` value in a JS collection and then calling `map` on could cause a web application to come to a screeching halt.  Especially in the web space, where there are countless external dependencies the developer cannot control (from external APIs to user interactions), it seems like a fantastic luxury to have this native wrapper around possible unsafe values which can handle them gracefully, without the cruft of try/catch blocks all over the place.

Wrapping possibly unsafe values is an important part of functional programming and provides great value to a developer.  The ease of implementing this practice in Scala is appetizing.
