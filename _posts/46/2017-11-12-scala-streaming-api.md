---
layout: post
title:  "scala streaming api"
date:   2017-11-12 14:18:19
categories: languages
excerpt: "a local data stream using scala"
tags:
  - kafka
  - streaming
  - jvm
---

[A few days ago](/tools/2017/11/10/intro-to-kafka-streams.html) I posted about my experimentation with the Kafka Streams api.  While I struggled a bit with the Scala/Java interop I have to say I am generally a fan of the API they created.  The concept of a "topology" was pretty cool.  The programmer is given an API to create "processor nodes" which are basically the steps that the data goes thru as it moves from the source topic to the sink topic.  

I thought it might be fun to try and implement a basic streaming API on my own.  In this example, I am reading data from a "source" file, mapping the data thru several node steps, then writing it to a "sink" file.  

My chosen data points are the lyrics from the Little Dragon song [Constant Surprises](https://www.youtube.com/watch?v=F3ZE1w6dLUs).  The API looks like this:

{% highlight scala %}
import com.lombardo.streaming.StreamInitializer

object Main {
  def main(args: Array[String]) {
    StreamInitializer
      .source("/constant_surprises.txt")
      .map(_.upCase)
      .map(_.mapValue(_.reverse))
      .map(_.mapKey(i => i * i))
      .sink("output.txt")
  }
}
{% endhighlight %}

Here are the components.


Our basic Message data class:
{% highlight scala %}
case class Message(key: Int, value: String)
{% endhighlight %}

a wrapper around our Message class allowing for access and transformations:
{% highlight scala %}
class Node(m: Message) {
  // identity operations
  override def toString = s"{% raw %}${m.key} -> ${m.value}{% endraw %}"
  def message = m
  def key = m.key
  def value = m.value
  // map operations
  def mapKey(f: (Int) => Int) = {
    val msg = new Message(f(m.key), m.value)
    new Node(msg)
  }
  def mapValue(f: (String) => String) = {
    val msg = new Message(m.key, f(m.value))
    new Node(msg)
  }
  def map(f: (Message) => Message) = {
    new Node(f(m))
  }
  // convenience shorthand map operations
  def upCase = new Node(m.copy(value = m.value.toUpperCase))
  def downCase = new Node(m.copy(value = m.value.toLowerCase))
}

// companion object for pretty instance construction
object Node {
  def apply(k: Int, v: String): Node = new Node(new Message(k,v))
}
{% endhighlight %}

When text is read in from a file, Scala will provide a `Iterator[String]`.  So for the purposes of my API construction I am wrapping the entire Iterator in a class called "StreamWrapper" that has a map operation included.  It also has a `sink` operation which we will get to soon.

{% highlight scala %}
import java.io.{BufferedWriter, File, FileWriter}

class StreamWrapper(stream: Iterator[Node]) {
  def map(f: (Node) => Node): StreamWrapper = {
    new StreamWrapper(stream.map(n => f(n)))
  }

  def sink(outputFile: String): Unit = {
    val file = new File(outputFile)
    val bw = new BufferedWriter(new FileWriter(file))
    while (stream.hasNext) bw.write(s"""${stream.next.toString}\n""")
    bw.close()
  }
}
{% endhighlight %}

Finally we need a way to start the stream.  We will wrap that operation in a `StreamInitializer` object.
The Scala way is `scala.io.Source.fromInputStream(file).getLines` which returns an `Iterator[String]`
Each `String` is wrapped in a `Node` case class, then all nodes are put into a `StreamWrapper`.

*note: `counterF()` is the [counter](/languages/2017/11/11/closures-in-scala.html) I wrote about yesterday, using it to give each message a sequence ID.*

{% highlight scala %}

import com.lombardo.utils.Helpers._

import scala.io.Source

object StreamInitializer {
  def source(file: String): StreamWrapper = {
    val counter = counterF()
    new StreamWrapper(
      Source
        .fromInputStream(getClass.getResourceAsStream(file))
        .getLines
        .map(value => new Node(Message(counter(), value)))
    )
  }
}

{% endhighlight %}


Now we are able to chain together a bunch of "nodes" and create a streaming topology:

{% highlight scala %}
StreamInitializer
  .source("/constant_surprises.txt")
  .map(_.upCase)
  .map(_.mapValue(_.reverse))
  .map(_.mapKey(i => i * i))
  .sink("output.txt")
{% endhighlight %}

For the future it would be cool to have the process tail the source file and send new lines into the stream whenever they are added. (for now it just reads the whole file and dumps it in one swift process)
