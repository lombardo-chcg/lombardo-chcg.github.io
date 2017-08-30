---
layout: post
title:  "speedy build tool REVERT"
date:   2017-08-29 08:21:54
categories: tools
excerpt: "uncaching dependencies in a scala sbt project"
tags:
  - scala
  - sbt
  - build
---

[A few weeks ago](/tools/2017/08/12/speedy-build-tool....html) I mentioned a cool way to cache dependency resolutions in an sbt project.  

Well, I forget to mention in that first post something important that the sbt folks have on the readme:

> Cached resolution is an experimental feature, and you might run into some issues.

Yep.  And if you do, here's a way to solve them.  Begin an `sbt` terminal session and enter the following commands:

{% highlight bash %}
> reload plugins
> update
> reload return
{% endhighlight %}

Source: [http://www.scala-sbt.org/0.13/docs/Dependency-Management-Flow.html](http://www.scala-sbt.org/0.13/docs/Dependency-Management-Flow.html)

I have a feeling just the `sbt update` command is the magic one, but I ran all three and got back to a working state.  I didn't have time to experiment.  And I removed the cached resolution feature for now. 
