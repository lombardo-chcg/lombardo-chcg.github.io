---
layout: post
title:  "the mandelbrot set II"
date:   2017-06-13 20:49:02
categories: fractal-nature
excerpt: "determining if a given complex number is part of the set"
tags:
  - imaginary-numbers
  - algorithms
---

[Last time](/languages/2017/06/11/the-Mandelbrot-set.html) we created a complex number prototype in JavaScript to use in our creation of a Mandelbrot Set visualization.  Today we implement the check to see if one of these complex numbers belongs in our set.

As a reminder, the formula we need to iterate on is: `Z = (Z*Z) + C`

The rules:
* `Z` starts at 0.  Every iteration generates a new value for `Z`, which we plug back in and run it again.  
* If `Z` exceeds a given *absolute value* at any point during the iteration, then `C` is not part of the Set.
* If we reach the end of the iteration and `Z` has never exceeded the given *absolute value*, then we have a number in the set.

We will use 2 as the absolute value which seems to be the standard for this calculation.

The iteration max is arbitrary in this case.  The higher the max, the more detail is provided in the set.

{% highlight javascript %}
var maxIterations = 100;

// params x, y are coordinates from a 2d graph
function isMandelbrotNum(x, y) {
  var z = new ComplexNumber(0, 0);
  var c = new ComplexNumber(x, y);

  for (var i = 0; i < maxIterations; i++) {
    z = z.times(z).plus(c);

    if (z.absoluteValue() > 2) {

      return false;
    }
  }

  return true;
}
{% endhighlight %}
