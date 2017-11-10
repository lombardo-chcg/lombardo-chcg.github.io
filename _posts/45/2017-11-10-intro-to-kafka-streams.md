---
layout: post
title:  "intro to kafka streams"
date:   2017-11-10 16:18:05
categories: tools
excerpt: "implementing a basic Kafka streams app in Scala"
tags:
  - apache
  - streaming
  - scala
  - java
---

I sat down to follow the [**Write a Streams Application**](https://kafka.apache.org/10/documentation/streams/tutorial) tutorial just to get a taste of the Streams API.  Boy was I in for a headache!

The API is implemented using some modern Java (JDK 8) and I found it did not play well with Scala AT ALL.  It was a pure bash-my-head-into-the-wall session until I got it working.

The problem was with the type-casting interop between Java and Scala.  It is not a clean interop.  Here's the code I used to convert part of that tutorial I mentioned above to Scala.  Once my headache goes away I may try to get a little further.

in `build.gradle`
{% highlight groovy %}
def scalaVersion = "2.11.8"
def log4jVersion = "2.9.1"
def kafkaVersion = "1.0.0"
dependencies {
    compile "org.scala-lang:scala-library:$scalaVersion"
    compile "org.scala-lang:scala-reflect:$scalaVersion"
    compile "org.apache.kafka:kafka-streams:$kafkaVersion"
    compile "org.apache.logging.log4j:log4j-api:$log4jVersion"
    runtime "org.apache.logging.log4j:log4j-core:$log4jVersion"
    runtime "org.apache.logging.log4j:log4j-slf4j-impl:$log4jVersion"
}
{% endhighlight %}

scala code:
{% highlight scala %}
package com.lombardo

import java.util.Properties

import org.apache.kafka.common.serialization.Serdes
import org.apache.kafka.streams.kstream.{KStream, ValueMapper}
import org.apache.kafka.streams.{KafkaStreams, StreamsBuilder, StreamsConfig}

class LineSplit {
  val props = new Properties
  props.put(StreamsConfig.APPLICATION_ID_CONFIG, "streams-pipe2")
  props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9091")
  props.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass())
  props.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass())

  val builder = new StreamsBuilder
  val source: KStream[String, String] = builder.stream("readings")

  // ugly, ugly, ugly hacking here.  need to find a better way to implement this
  source.mapValues[String](new ValueMapper[String, String] {
    override def apply(value: String): String = {
      value.toUpperCase
    }
  }).to("my-output-topic")

  val topology = builder.build
  val streams = new KafkaStreams(topology, props)
  streams.start
}


{% endhighlight %}
