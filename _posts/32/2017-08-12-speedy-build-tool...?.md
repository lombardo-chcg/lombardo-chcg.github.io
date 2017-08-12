---
layout: post
title:  "speedy build tool...?"
date:   2017-08-12 09:23:08
categories: tools
excerpt: "increasing sbt performance thru cached dependency resolution"
tags:
  - scala
  - scalatra
---

[sbt](http://www.scala-sbt.org/index.html) is a point of contention among JVM developers.  I personally don't mind it, especially as I learn more about it.  But those that come from the background of Maven or Gradle seem to have big issues with sbt.

One problem that all build tools have in common is the time it takes to resolve a project's dependency graph.  sbt is notorious for how long this takes and the amount of resources it consumes (laptop battery, cpu, etc).  And this becomes a even bigger problem on continuously deployed projects, as new builds are constantly being compiled and deployed.

Turns out that sbt has a 'Cached Resolution' feature to address this issue.

Today I added the Cached Resolution feature to my [scrabble-helper-api](https://github.com/lombardo-chcg/scrabble-helper-api) project:

in `build.sbt`:
{% highlight scala %}
updateOptions := updateOptions.value.withCachedResolution(true)
{% endhighlight %}

And here are the results of running `sbt compile`:

* before: Total time 35 s
* after: Total time 3 s

And going forward, sbt will only resolve new or changed dependencies, loading the unchanged resolutions from local storage @ `~/.sbt/0.13/dependency/` (If you explore that directory you will see that each library has a massive JSON file associated with it that describes its dependencies).  For example I changed one piece of source code in the project and the build time was 15s, still a massive improvement.

Here's the sbt writeup on this feature, which includes some cool discussions of the nature of dependency resolution: [http://www.scala-sbt.org/0.13/docs/Cached-Resolution.html](http://www.scala-sbt.org/0.13/docs/Cached-Resolution.html)
