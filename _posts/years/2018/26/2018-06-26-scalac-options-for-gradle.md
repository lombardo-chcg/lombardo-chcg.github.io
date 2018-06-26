---
layout: post
title:  "Scala compiler options with Gradle"
date:   2018-06-26 11:25:49
categories: languages
excerpt: "how to pass compiler flags to the scalac compiler when using Gradle"
tags:
  - scala
  - gradle
  - sbt
---

The purpose here is to bookmark this post which shows how to pass flags to the `scalac` compiler when using the Scala plugin with Gradle:

[http://blog.vorona.ca/compile-options-for-scala-in-gradle.html](http://blog.vorona.ca/compile-options-for-scala-in-gradle.html)

--

Here's a sample `build.gradle` in full: 

{% highlight groovy %}
plugins {
    id "scala"
}

repositories {
    mavenCentral()
}

tasks.withType(ScalaCompile) {
    scalaCompileOptions.additionalParameters = ["-feature", "-language:implicitConversions"]
}

ext {
    scalaVersion = "2.13.0-M4"
}

dependencies {
    compile "org.scala-lang:scala-library:$scalaVersion"
    compile "org.scala-lang:scala-reflect:$scalaVersion"
}

{% endhighlight %}

As a reminder, `man scalac` will show all the available compiler options.  They can also be accessed via the Scala docs: [https://docs.scala-lang.org/overviews/compiler-options/index.html](https://docs.scala-lang.org/overviews/compiler-options/index.html)

To confirm it's working sneak something like this into your code: `trait Fancy[A[_]]`, then check the compiler output before and after adding the flags.
