---
layout: post
title:  "quite a john hancock"
date:   2017-02-15 20:15:47
categories: languages
excerpt: "deciphering scala function signatures"
tags:
  - scala
---

Today I was using the JSON4s (JSON for Scala) library and was confronted by the following method signature:

{% highlight scala %}
def find(p: JValue => Boolean): Option[JValue]
{% endhighlight %}

Scala has a reputation for being a complex and academic language and this is an example of why that is the case.  So is going on here?

We have a method called `find` and its single param is `(p: JValue => Boolean)`.  This can be interpreted as an anonymous function that takes type `JValue` as its input (represented here by `p`), and returns a Boolean.  So, the method `find` takes an anonymous function as its argument.

The return value is an Option with type `JValue`.  [As you recall from last week's post]({{ full_base_url }}/languages/2017/02/10/Option-Type.html), an Option in Scala is a wrapper around a potentially unsafe value.  The Some class is allowed to peek into the Option class to see if there is a value present, without throwing an exception if no value exists.

So in plain English, this `def` function takes an anonymous function as an argument, and based on the return value of that anonymous function, it returns an Option.  Got it??

Challenge: try implementing this signature with a function in your language of choice.  I may follow up soon with a post translating Scala code like this to JavaScript.
