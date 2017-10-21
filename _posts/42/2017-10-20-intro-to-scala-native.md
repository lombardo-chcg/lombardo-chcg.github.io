---
layout: post
title:  "intro to scala native"
date:   2017-10-20 07:41:37
categories: languages
excerpt: "running scala without the jvm"
tags:
  - scala
---

Normally the Scala complier creates JVM bytecode.  This of course means Scala can leverage all the power of the JVM.  But it also means that to run any Scala code, one must start a JVM and wait for it to warm up before any code can be executed.

Scala Native aims to free Scala from the JVM.  Instead, Scala Native compiles down to "native executables", which is a way to say that the Scala code is converted to assembly-level code for whatever platform the user is running (totally bypassing the JVM runtime stuff).

The use cases are fairly narrow, but when appropriate this approach can yield a lot of power.  For example, simple command line scripting tools or high-performance hot path situations.  Let's build a quick example app to see what it's all about.

[Check out the full installation instructions](http://www.scala-native.org/en/latest/user/setup.html) from the Scala Native project site.  Here's what I did to get up an running on my Mac OSX running El Capitain:  

{% highlight bash %}
brew install llvm

sbt new scala-native/scala-native.g8

sbt run

# [error] fatal error: 'gc.h' file not found
# [error] #include <gc.h>
{% endhighlight %}

Huh?  What is that all about?

Turns out there is are two optional dependencies listed on the Scala Native site that might not be so optional.  Especially the [`bdw-gc`](http://braumeister.org/formula/bdw-gc) garbage collector.  The other listing, [`re2`](https://libraries.io/homebrew/re2) is a RegEx library.  So that may come in handy sometime.   Continuing the install:

{% highlight bash %}
brew install bdw-gc re2

sbt clean run

# Hello, World!
{% endhighlight %}

Native Code!  That was super cool.  Lets try to implement one of the classic Unix command line tools in Scala and see how it performs.  I chose `cat`.


In the project, change `src/main/scala/Hello.scala` to contain the following code:

{% highlight scala %}
import scala.io.Source

object Hello extends App {
  if (args.length == 0) println("must supply a filename")
  else {
    val filename = args(0)
    for (line <- Source.fromFile(filename).getLines) {
      println(line)
    }
  }
}
{% endhighlight %}

Since our `sbt run` command created a native executable, we can call that native executable directly and pass it a file:

{% highlight bash %}
./target/scala-2.11/scala-native-out sample.txt
{% endhighlight %}

It executes instantly.  Amazing!  Let's do a performance comparison of the native bytecode vs. the same exact code but executed by the Scala complier (which spins up a JVM before executing)

I created a file called `regular-scala.scala` and put the same exact code from above ^^ into it.

{% highlight bash %}
START=$(date +%s); scala regular-scala.scala sample.txt; END=$(date +%s)
# ...
echo $(($END - $START))
# 3 (ms)
{% endhighlight %}

Now for the Scala native:
{% highlight bash %}
START=$(date +%s); ./target/scala-2.11/scala-native-out sample.txt; END=$(date +%s)
# ...
echo $(($END - $START))
# 0 (ms)
{% endhighlight %}

That's amazing.  I want to use Scala Native to create a command line tool for sure.
