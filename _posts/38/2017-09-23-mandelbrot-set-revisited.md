---
layout: post
title:  "mandelbrot set revisited"
date:   2017-09-23 17:08:21
categories: fractal-nature
excerpt: "experimenting with the equation which produces the set"
tags:
  - javascript
  - imaginary-numbers
  - algorithms
---

I have a developed an unending fascination with [The Mandelbrot Set](https://lombardo-chcg.github.io/search?term=mandelbrot).  

One of the set's most well-known features is the [cardioid](https://en.wikipedia.org/wiki/Cardioid) which makes up the inner bulb shape.  [This really cool video](https://www.youtube.com/watch?v=qhbuKbxJsk8) explains how to create a cardioid using a circle and a simple multiplication table.

The formula to construct the traditional Set is `Z = (Z*Z) + C`.  Inspired by the video, I updated my [OOJS Mandelbrot Set](https://github.com/lombardo-chcg/OOJS-Mandelbrot-Set) project to use a slightly different formula:

{% highlight bash %}
Z = (Z*Z*Z) + C
{% endhighlight %}

The resulting image now features a nephroid as the primary feature, instead of a cardioid.  Nephroid means `kidney-shaped`.

In the first case, our exponent was 2 and we saw 1 bulb.  In this case, our exponent is 3 and we see two bulbs.  This pattern continues: as the exponent `(n)` value increases, the number of bulbs is `n - 1`.  These shapes are known as [Epicycloids](https://en.wikipedia.org/wiki/Epicycloid).


[*images generated with https://github.com/lombardo-chcg/OOJS-Mandelbrot-Set*](https://github.com/lombardo-chcg/OOJS-Mandelbrot-Set)

--

{% highlight bash %}
Z = (Z**3) + C
{% endhighlight %}
![nephroid mandelbrot set]({{ full_base_url }}/media/nephroid_mandelbrot.png)

--

{% highlight bash %}
Z = (Z**4) + C
{% endhighlight %}
![three bulb mandelbrot]({{ full_base_url }}/media/three_bulb_mandelbrot.png)

--

{% highlight bash %}
Z = (Z**10) + C
{% endhighlight %}
![nine bulb mandelbrot]({{ full_base_url }}/media/nine_bulb_mandelbrot.png)
