---
layout: post
title:  "the mandelbrot set, part 1"
date:   2017-06-11 19:13:24
categories: fractal-nature
excerpt: "working with complex numbers in javascript to create fractal geometry"
tags:
  - imaginary-numbers
  - algorithms
---

The [Mandelbrot Set](https://en.wikipedia.org/wiki/Mandelbrot_set) is a thing of beauty.  At its core, it is very simple: it is a 2D graph that shows a point for every coordinate location that matches a rule.  It is a common way to show the beauty of fractal geometry.

I randomly became interested in the Mandelbrot Set today and decided I would write a quick program to create a visual representation of it.

The beauty of the Mandelbrot Set and the images based on it are based on a simple foundation.  

We start with a number, call it `C`.  We need a process is to determine if `C` is part of the Mandelbrot Set.

We determine this by running `C` thru an equation a set number of times, a.k.a. we iterate on it.  The equation is:

{% highlight bash %}
Z = (Z*Z) + C
{% endhighlight %}
The rules:
* `Z` starts at 0.  Every iteration generates a new value for `Z`, which we plug back in and run it again.  
* If `Z` exceeds a given *absolute value* at any point during the iteration, then `C` is not part of the Set.
* If we reach the end of the iteration and `Z` has never exceeded the given *absolute value*, then we have a number in the set.

So numbers that are in the Set get caught in an infinite loop where they never "break out" of the box created by the basic rules.

Seems easy right?  Well here's the catch: the numbers in the equation are "complex numbers."

I started no knowing anything about complex numbers, and their definition sounds intimidating:

> A complex number is a number that can be expressed in the form a + bi, where a and b are real numbers and i is the imaginary unit, satisfying the equation i2 = −1 (wikipedia)

Imaginary unit?  huh?

Sounds complicated, but really, I think we're just talking about a set of coordinates on a 2 dimensional graph.  Like the old game, Battleship.  For example the coordinates of `3,1` would be represented as the complex number `3 + 1i`

So we need to do the basic equation above, under iteration, using complex numbers.

Since I planned to make a visual representation, I decided to write the code in JavaScript, and I went with an Object Oriented approach based on a `ComplexNumber` constructor function.

{% highlight javascript %}
// C = A + Bi

var ComplexNumber = function(x, y) {
    this.a = x;
    this.b = y;
}
{% endhighlight %}

As a reminder, our equation is:
{% highlight bash %}
Z = (Z*Z) + C
{% endhighlight %}

And I want to represent that in JavaScript like this:

{% highlight JavaScript %}
var z = new ComplexNumber(0, 0);
var c = new ComplexNumber(x, y);

z = z.times(z).plus(c);
{% endhighlight %}

So we will need to give some added features to our `ComplexNumber` object constructor, to perform addition and multiplication of our complex numbers.   Here's the code:

addition:
{% highlight JavaScript %}
// param 'that' : instance of ComplexNumber
ComplexNumber.prototype.plus = function(that) {
    return new ComplexNumber(
        this.a + that.a,
        this.b + that.b
    );
}
{% endhighlight %}

multiplication [(based on this formula)](https://en.wikipedia.org/wiki/Complex_number#Multiplication_and_division)
{% highlight javascript %}
// param 'that' : instance of ComplexNumber
ComplexNumber.prototype.times = function(that) {
    return new ComplexNumber(
        (this.a * that.a) - (this.b * that.b),
        (this.b * that.a) + (this.a * that.b)
    );
}
{% endhighlight %}

We also need to be able to extract the absolute value [(based on this formula)](https://en.wikipedia.org/wiki/Complex_number#Absolute_value_and_argument)
{% highlight javascript %}
ComplexNumber.prototype.absoluteValue = function() {
    return Math.sqrt(
        (this.a ** this.a) + (this.b ** this.b)
    );
}
{% endhighlight %}

Alright.  We've got our complex number handler all set up and ready to roll.  In the next post, we'll start iterating and creating the Set.
