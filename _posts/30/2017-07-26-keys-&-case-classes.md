---
layout: post
title:  "hey mr postman"
date:   2017-07-26 21:44:36
categories: exploration
excerpt: "playing around with the kafka producer api and extending my docker-for-mac kafka stack"
tags:
  - kafka
  - scala
  - scalatra
  - keys
  - class
  - case
---

This will be a bit of a free form post.

[As I said in my last post](tools/2017/07/23/confluent-stack-on-docker-for-mac.html) I am looking to set up some Kafka infrastructure on my own terms and really get to know how it works.

So I decided to start at the "front" of a Kafka pipeline, by making a `Producer` of messages.

I used my [Scalatra Starter Pack](/web-programming/2017/06/20/scalatra-starter-pack.html) to create a quick, http mini-service that accepts JSON and publishes that input as Kafka messages.

I started checking out the [`Class ProducerRecord`](https://kafka.apache.org/0100/javadoc/index.html?org/apache/kafka/clients/producer/KafkaProducer.html) docs on the Apache site, and noticed that it is possible to publish Kafka records both with a key, and without a key.  One use case for a key would be a unique ID, or some type of numbering system so consumers can organize the records.  Useful, but not required.

So here's a super basic Message class and Kafka Producer wrapper class written in Scala, that allows the user to send a message with a key or without:

{% highlight scala %}
package com.lombardo.app.kafka

import java.util.Properties
import org.apache.kafka.clients.producer._

// key is an Option type, defaulted to a None
case class Message(topic: String, key: Option[String] = None, content: String)

class MessengerService {
  val props = new Properties()

  props.put("bootstrap.servers", "YOUR_KAFKA_HOST:AND_PORT")
  props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer")
  props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer")

  val producer = new KafkaProducer[String, String](props)

  def send(msg: Message) = {
    val record = msg match {
      case Message(_, Some(_), _) => new ProducerRecord(msg.topic, msg.key.get, msg.content)
      case _ => new ProducerRecord[String, String](msg.topic, msg.content)
    }

    producer.send(record)
  }
}
{% endhighlight %}

An Scalatra endpoint could then be written like this:

{% highlight scala %}
post("/messages") {
  val message = parsedBody.extract[Message]
  log.info(message.toString)

  messengerService.send(message)
}
{% endhighlight %}

and it could accept JSON in either format, not caring either way:

{% highlight JSON %}
{
  "topic": "readings",
  "key": "3214-aefcb",
  "content": "-20"
}

// or

{
  "topic": "readings",
  "content": "-30"
}
{% endhighlight %}

I added my mini-producer service to [this `docker-compose.yml` file: https://github.com/lombardo-chcg/kafka-local-stack/blob/master/docker-compose.yml](https://github.com/lombardo-chcg/kafka-local-stack/blob/master/docker-compose.yml)

Let's start up the stack and confirm it works.  `docker-compose up -d`

Send the `POST` requests mentioned above to `localhost:8080/messages`

{% highlight bash %}
curl -X POST \
  http://localhost:8080/messages \
  -H 'content-type: application/json' \
  -d '{
    "topic": "readings",
    "key": "3214-aefcb",
    "content": "-20"
  }'

curl -X POST \
  http://localhost:8080/messages \
  -H 'content-type: application/json' \
  -d '{
    "topic": "readings",
    "content": "-30"
  }'  
{% endhighlight %}

Then fire up a console consumer:

{% highlight bash %}
docker exec -it kafka-cli bash

./kafka-console-consumer.sh \
  --bootstrap-server kafka:9092 \
  --topic readings \
  --from-beginning \
  --property print.key=true \
  --property key.separator=": "

  # 3214-aefcb: -20
  # null: -30
{% endhighlight %}
