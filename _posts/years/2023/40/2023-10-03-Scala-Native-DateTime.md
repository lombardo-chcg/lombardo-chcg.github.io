---
layout: post
title:  "Scala Native - do you have the time?"
date:   2023-10-03 22:44:49
categories: "tools"
excerpt: "working with dates and times in Scala Native"
tags:
  - scala
  - scala native
  - jvm
  - sbt
---

Coming from a JVM background, it is natural to reach for members of the `java.time` package while writing programs.  

I recently started playing around with [Scala Native](https://github.com/scala-native/scala-native) for a personal project, and was surprised to see that this classic Java package is not supported out of the box by Scala Native.  

So what are the options?  I noticed that the `java.util` package has been ported to Scala Native ([reference](https://scala-native.org/en/latest/lib/javalib.html)), with ancient classes like `java.util.Date` and `java.util.Calendar` included.  But once I went down that rabbit hole, I found that methods on `java.util.Calendar` which are needed to make a `java.util.Date` instance usable are not yet implemented either.  So that was a no-go.

Luckily, there are a few 3rd party libraries to help us out.  I ended up choosing `scala-java-time` ([link](http://cquiroz.github.io/scala-java-time/)) which implements the `java.time` APIs for Scala Native (and JS).  So far, it is working great.  I'm able to use classes like `Instant` `ZoneId`, `LocalDate`, etc with ease thanks to this library.

Some snippets from my `build.sbt` file with dependency info:

```
ThisBuild / scalaVersion := "2.13.11"

// version of the library (using explicit syntax for now instead of sbt shortcuts)
"io.github.cquiroz" % "scala-java-time_native0.4_2.13" % "2.5.0"
```

and in `project/plugins.sbt`:
```
addSbtPlugin("org.scala-native" % "sbt-scala-native" % "0.4.15")
```