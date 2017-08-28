---
layout: post
title:  "scala tests"
date:   2017-08-26 18:59:56
categories: testing
excerpt: "running unit tests in an sbt project"
tags:
  - scala
  - unit
  - sbt
---

I just upgraded my [sbt project starter](https://github.com/lombardo-chcg/sbt-project-starter) to include a basic unit test setup.

The [sbt user guide](http://www.scala-sbt.org/0.13/docs/Testing.html) provides the fundamentals of how to setup the these tests.  Here are the basic steps:

1. ensure you have a `src/test/scala/` path in the project
2. update `build.sbt` to include the test framework dependency
* note: the `test` configuration is how to tell sbt to only include the test dependencies on the "test classpath"
3. add a basic test in the test classpath

[*commit that shows this work*](https://github.com/lombardo-chcg/sbt-project-starter/commit/1480d6484032d9332707aa32e15bee337e5bb5ee)


Now the tests can be run thru IntelliJ by `ctrl`-clicking the test class name.  Or they can be run from the terminal:
{% highlight bash %}
sbt clean compile test
{% endhighlight %}
