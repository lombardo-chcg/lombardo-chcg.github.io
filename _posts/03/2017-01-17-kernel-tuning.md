---
layout: post
title:  "kernel tuning"
date:   2017-01-17 22:14:16
categories: "mixed bag"
excerpt: "fun facts about low latency trading systems"
tags:
  - "c++"
---
Today watched a [video](https://www.youtube.com/watch?v=ulOLGX3HNCI&t=3197s) about high-speed trading systems in C++ and learned some wicked cool stuff from Carl Cook.

These trading firms will go to great lengths to be nanoseconds faster than the competition.

- High-frequency trading firms use microwave towers to receive market data and transmit orders, as this transmission method is closer to the speed of light than fiber optics.
- Servers and operating systems are designed for maximum throughput (performing maximum number of actions during a unit of measure).  High-speed trading firms are more interested in lower latency(the required time to perform an action) go so far as to tune the Linux kernel towards this end.
- Cook suggested reading the assembly code looking to see what the compiler is doing, and to look for bad patterns to kill.
- It is possible to use the user space and have your code read/write network packets directly to the network card, instead of making system calls in the kernel space.  Another way to lower latency.
- A single process is better than two(?!?!) says Cook and I love it.  This is the whole idea being Node.js which I also love.  Multi-threading just doesn't seem like something humans should be telling computers to do.  IMO threads shouldn't be exposed in the application layer.
- He also mentioned other code basics such as avoiding complex else/if statements in the "hotpath" and tricks like this:
{% highlight bash %}
if (lowCostComparison || highCostComparison) {};
# instead of
if (highCostComparison || lowCostComparison) {};
{% endhighlight %}
this stops the processing as soon as possible and lowers latency.

Whether or not these firms are adding any value to the market with their high-speed techniques is another debate entirely.  They will claim they add liquidity...I guess. I got burned in the options market a few years back and I now don't put a lot of faith in the idea of applying models to an irrational market.  It's like collecting pennies in front of a steamroller.  I'm now a buy-and-hold guy.
