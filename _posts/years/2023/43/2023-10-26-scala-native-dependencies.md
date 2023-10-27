---
layout: post
title:  "Scala Native Dependencies"
date:   2023-10-26 21:29:48
categories: "tools"
excerpt: "A quick-start list of dependencies for a Scala Native project"
tags:
  - scala
  - scala native
  - jvm
  - sbt
---

I'm working on a side project, building a cli app with Scala Native.  Since the libraries available for Scala Native are a subset of the libraries available for JVM Scala, it can be tricky to find the basic libraries + versions to perform basic tasks when getting started.  So this post will be a way to keep track of a group of libraries that work well together for building a practical Scala Native app.

## Dependencies

A few things that we can accomplish with this list of dependencies:

- working with files and processes (OS-Lib)
- handling JSON that you might write to disk with OS-Lib (circe)
- building a subcommand-style cli interface like `kubectl`
- doing anything you would normally do with the `java.time` APIs (which is not available by default in scala native)

```scala
import sbt._

object Dependencies {
  lazy val munit = "org.scalameta" %% "munit" % "0.7.29" % Test

  val circeVersion = "0.14.3"
  val circe = Seq(
    "io.circe" % "circe-core_native0.4_2.13" % circeVersion,
    "io.circe" % "circe-generic_native0.4_2.13" % circeVersion,
    "io.circe" % "circe-generic-extras_native0.4_2.13" % circeVersion,
    "io.circe" % "circe-parser_native0.4_2.13" % circeVersion
  )

  val osLib = "com.lihaoyi" % "os-lib_native0.4_2.13" % "0.9.1"

  val decline = "com.monovore" % "decline_native0.4_2.13" % "2.2.0"

  val javaTime = "io.github.cquiroz" % "scala-java-time_native0.4_2.13" % "2.5.0"
}
```

Note that I am being explicit with the Scala version in this example, e.g. including `_native0.4_2.13` in each module name.

A more "sbt" way to define these dependencies is to use the `%%%` dependency builder.  I don't really care, I find sbt unpronounceable operators to be an unnecessary abstraction. 


## build file

Here's a full `build.sbt` for reference, that includes all the Scala Native goodies.  

And for reference, `sbt.version=1.9.6`. (defined in `project/build.properties`)

```scala
import Dependencies._

ThisBuild / scalaVersion := "2.13.11"
ThisBuild / version := "0.1.0-SNAPSHOT"
ThisBuild / organization := "com.example"
ThisBuild / organizationName := "example"

enablePlugins(ScalaNativePlugin)

scalacOptions ++= Seq(
  "-Xfatal-warnings",
  "-deprecation"
)

lazy val root = (project in file("."))
  .settings(
    name := "my-cool-project",
    libraryDependencies ++= Seq(
      osLib,
      decline,
      javaTime
    ) ++ circe :+ munit
  )

// set to Debug for compilation details (Info is default)
logLevel := Level.Info

// import to add Scala Native options
import scala.scalanative.build._

// defaults set with common options shown
nativeConfig ~= { c =>
  c.withLTO(LTO.none) // thin
    .withMode(Mode.debug) // releaseFast
    .withGC(GC.immix) // commix
}
```

## plugins

And the plugins in use (`./project/plugins.sbt`):

```scala
addSbtPlugin("org.scala-native" % "sbt-scala-native" % "0.4.15")
addSbtPlugin("org.scalameta" % "sbt-scalafmt" % "2.4.6")
```

## next
If I add more dependencies, I'll try to add them here.  For example, an http client lib.