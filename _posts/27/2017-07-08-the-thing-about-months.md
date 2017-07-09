---
layout: post
title:  "the thing about months"
date:   2017-07-08 20:56:16
categories: languages
excerpt: "a weird quirk in JavaScript's Date constructor is a holdover from days gone by"
tags:
  - JavaScript
  - Java
  - history
---

In a browser JS console or Node terminal session, enter the following:

{% highlight javascript %}
var x = new Date(2017,1,1);
{% endhighlight %}

The expectation would be this would create a new `Date` object representing Jan. 1, 2017.

But what really happens?

{% highlight javascript %}
console.log(x);
// 2017-02-01T06:00:00.000Z
{% endhighlight %}

Huh?  We put in Jan 1st and got Feb 1st?  WTF...?

Turns out that months are zero-indexed so January is `0` and Dec. is `11`.

{% highlight javascript %}
var xy = new Date(2017,0,1);
console.log(xy);
// 2017-01-01T06:00:00.000Z
{% endhighlight %}

[Here's a Stack Overflow post](https://stackoverflow.com/questions/2552483/why-does-the-month-argument-range-from-0-to-11-in-javascripts-date-constructor) explaining the lineage of this implementation.  The twitter posts from Brendan Eich are especially interesting.
