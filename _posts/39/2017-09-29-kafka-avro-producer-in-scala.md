---
layout: post
title:  "kafka avro producer example in scala"
date:   2017-09-29 23:46:06
categories: tools
excerpt: "example of a avro serializing kafka producer in scala"
tags:
  - apache
  - kafka
  - scala
  - avro
---

Here's a quick example of how to create a Kafka Producer that sends [Avro-serialized](http://avro.apache.org/docs/1.8.2/) messages.

Important Note: a running instance of the Confluent Schema Registry is required to produce Avro messages.  Why?  

> When sending a message to a topic t, the Avro schema for the key and the value will be automatically registered in the schema registry under the subject t-key and t-value, respectively, if the compatibility test passes.

##### [*source: https://docs.confluent.io/3.2.1/schema-registry/docs/serializer-formatter.html#serializer*](https://docs.confluent.io/3.2.1/schema-registry/docs/serializer-formatter.html#serializer)

The ID of the schema is then embedded in the serialized message, in bytes 1-4.  My guess is so a consumer will be able to pull the schema and deserialize the message.  TODO: confirm that.

First, the dependencies:

`build.sbt`
{% highlight scala %}
name := "avro-junkie"

version := "0.0.1"

mainClass in assembly := Some("com.lombardo.avroJunkie.Main")

scalaVersion := "2.11.8"

resolvers ++= Seq(
  Classpaths.typesafeReleases,
  "confluent" at "http://packages.confluent.io/maven/"
)

libraryDependencies ++= Seq(
  "org.scalatest" %% "scalatest" % "3.0.1" % "test",
  "org.apache.kafka" % "kafka_2.11" % "0.10.0.0",
  "org.apache.avro" % "avro" % "1.8.2",
  "io.confluent" % "kafka-avro-serializer" % "3.2.1"
)
{% endhighlight %}

{% highlight scala %}
package com.lombardo.avroJunkie.services

import java.util.Properties

import org.apache.avro.Schema.Parser
import org.apache.avro.generic.GenericData
import org.apache.kafka.clients.producer.{KafkaProducer, ProducerRecord}
import org.slf4j.LoggerFactory

case class User(name: String, favoriteNumber: Int, favoriteColor: String)

class AvroProducer {
  val logger = LoggerFactory.getLogger(getClass)

  val kafkaBootstrapServer = sys.env("KAFKA_BOOTSTRAP_SERVER")
  val schemaRegistryUrl = sys.env("SCHEMA_REGISTRY_URL")

  val props = new Properties()
  props.put("bootstrap.servers", kafkaBootstrapServer)
  props.put("schema.registry.url", schemaRegistryUrl)
  props.put("key.serializer", "io.confluent.kafka.serializers.KafkaAvroSerializer")
  props.put("value.serializer", "io.confluent.kafka.serializers.KafkaAvroSerializer")
  props.put("acks", "1")

  val producer = new KafkaProducer[String, GenericData.Record](props)
  val schemaParser = new Parser

  val key = "key1"
  val valueSchemaJson =
  s"""
    {
      "namespace": "com.avro.junkie",
      "type": "record",
      "name": "User2",
      "fields": [
        {"name": "name", "type": "string"},
        {"name": "favoriteNumber",  "type": "int"},
        {"name": "favoriteColor", "type": "string"}
      ]
    }
  """
  val valueSchemaAvro = schemaParser.parse(valueSchemaJson)
  val avroRecord = new GenericData.Record(valueSchemaAvro)

  val mary = new User("Mary", 840, "Green")
  avroRecord.put("name", mary.name)
  avroRecord.put("favoriteNumber", mary.favoriteNumber)
  avroRecord.put("favoriteColor", mary.favoriteColor)

  def start = {
    try {
      val record = new ProducerRecord("users", key, avroRecord)
      val ack = producer.send(record).get()
      // grabbing the ack and logging for visibility
      logger.info(s"${ack.toString} written to partition ${ack.partition.toString}")
    }
    catch {
      case e: Throwable => logger.error(e.getMessage, e)
    }
  }
}
{% endhighlight %}

Here's a main class to get this to run (and that handles the log4j configuration for the Apache dependencies)

{% highlight scala %}
package com.lombardo.avroJunkie

import com.lombardo.avroJunkie.services.AvroProducer
import org.apache.log4j.BasicConfigurator
import org.slf4j.LoggerFactory

object Main {
  def main(args: Array[String]) {
    BasicConfigurator.configure()
    val logger = LoggerFactory.getLogger(getClass)
    logger.info("Starting the application")

    val producer = new AvroProducer
    producer.start
  }
}
{% endhighlight %}
