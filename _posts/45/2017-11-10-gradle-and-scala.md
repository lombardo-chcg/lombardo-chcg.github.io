---
layout: post
title:  "gradle and scala"
date:   2017-11-10 12:10:07
categories: tools
excerpt: "basic scaffolding for a Scala project built with Gradle"
tags:
  - scala
  - gradle
  - java
  - jvm
  - sbt
---

Here's a quick starter pack to get up and running quickly building a Scala project with Gradle:
[https://github.com/lombardo-chcg/scala-gradle-starter](https://github.com/lombardo-chcg/scala-gradle-starter)

I've been using Gradle with Scala for a few weeks now and honestly it has been a great experience.  SBT is fun but Gradle seems like a much more dependable and "google-able" tool.


--

The [`build.gradle`](https://github.com/lombardo-chcg/scala-gradle-starter/blob/master/build.gradle) file contains annotations for the various dependencies etc.

The author of the Scalatest plugin has decided to include a HTML test report generator, which requires an additional dependency, `pegdown`.  To see the reports run this terminal command after running your tests:
{% highlight bash %}
open build/reports/tests/test/index.html
{% endhighlight %}

--


If you see this error after importing the project into Intellij:
{% highlight bash %}
Details: groovy.lang.MissingPropertyException: No such property: daemonServer for class: org.gradle.api.tasks.scala.ScalaCompileOptions
{% endhighlight %}

My solution was to upgrade my version of Intellij.  I was previously on `2016.2.x Community` and upgraded to `2017.2.5 Community`

*[Source: https://www.mail-archive.com/users@kafka.apache.org/msg24169.html](https://www.mail-archive.com/users@kafka.apache.org/msg24169.html)*
