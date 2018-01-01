---
layout: post
title:  "making music"
date:   2017-12-30 12:45:05
categories: tools
excerpt: "playing around with the JFugue library in Scala"
tags:
  - music
  - art
  - repl
  - scala
  - jvm
  - java
---

The [JFugue](http://www.jfugue.org/index.html) library is a cool way to make music programmatically!

Here's a quick way to sandbox it in scala.

Start by making a new directory.  Then,

{% highlight bash %}
wget http://www.jfugue.org/jfugue-5.0.9.jar
scala
{% endhighlight %}

inside scala repl (turn on your speakers!):

{% highlight scala %}
:require jfugue-5.0.9.jar
/*
* Added 'jfugue/jfugue-5.0.9.jar' to classpath.
*/

import org.jfugue.player.Player

val player = new Player()

player.play("C E G B G E")
{% endhighlight %}

If you prefer to sandbox in a file, it is possible to quickly execute the file as a script with the library on the classpath by executing the following:

{% highlight bash %}
scala -classpath jfugue-5.0.9.jar MyDemoScript.scala
{% endhighlight %}
