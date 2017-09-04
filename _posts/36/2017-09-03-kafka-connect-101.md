---
layout: post
title:  "kafka connect 101 (docker edition)"
date:   2017-09-03 17:05:25
categories: tools
excerpt: "walking thru a configuration of the kafka connect application"
tags:
  - confluent
  - apache
  - kafka
  - docker
---

[Kafka Connect](https://www.confluent.io/product/connectors/) is a tool that allows a developer to easily connect a Kafka system to external data sources and sinks.

A quick walkthru:
* There are many common use patterns amongst Kafka users.  For example, streaming input data from a SQL database or landing data in a Elasticsearch cluster.
* Kafka Connect provides an abstraction (API layer) over these common connection patterns
* Developers can then write "configurations" instead of application code to connect new data sources and sinks to Kafka

While that sounds simple, there are definitely some nuances in the details.  The point of this first post is to explore the basic configuration for getting a Connect instance running in a broader system.

For this demo, we will be extending my [kafka & docker local stack](https://github.com/lombardo-chcg/kafka-local-stack).

First we start with the Kafka Connect docker image which matches the rest of the stack:
{% highlight bash %}
image: "confluentinc/cp-kafka-connect:3.2.1"
{% endhighlight %}

Next let's review the various environment variables needed by Kafka Connect.

Per the [docs](http://docs.confluent.io/current/cp-docker-images/docs/configuration.html#kafka-connect):

> The Kafka Connect image uses variables prefixed with CONNECT_ with an underscore (_) separating each word instead of periods

i.e. `bootstrap.servers` -> `CONNECT_BOOTSTRAP_SERVERS`

Here's a list of all the app's [required settings](http://docs.confluent.io/current/cp-docker-images/docs/configuration.html#id5).  I will divide them into 3 logical categories for the purposes of this hello-world style intro.

First, networking settings:
{% highlight bash %}
# networking
CONNECT_BOOTSTRAP_SERVERS: "kafka:9092"
CONNECT_REST_ADVERTISED_HOST_NAME: "kafka_connect"
CONNECT_REST_PORT: "8083"
{% endhighlight %}

--

Next, "kafka" settings.  
* Kafka Connect instances are stateless - all state lives in Kafka Topics
* This includes all configuration info
* Topic are created automatically when specified here - no setup needed
{% highlight bash %}
# kafka
CONNECT_GROUP_ID: "readings-connect"
CONNECT_CONFIG_STORAGE_TOPIC: "readings-config"
CONNECT_OFFSET_STORAGE_TOPIC: "readings-offset"
CONNECT_STATUS_STORAGE_TOPIC: "readings-status"
{% endhighlight %}

--

Finally, the convertors.  
* Convertors determine the data format that Kafka Connect uses to serialize/deserialize Kafka messages
* Available converters include:
* `org.apache.kafka.connect.storage.StringConverter`
* `org.apache.kafka.connect.json.JsonConverter`
* `io.confluent.connect.avro.AvroConverter`
{% highlight bash %}
# convertors
CONNECT_KEY_CONVERTER: "org.apache.kafka.connect.storage.StringConverter"
CONNECT_VALUE_CONVERTER: "org.apache.kafka.connect.storage.StringConverter"
CONNECT_INTERNAL_KEY_CONVERTER: "org.apache.kafka.connect.json.JsonConverter"
CONNECT_INTERNAL_VALUE_CONVERTER: "org.apache.kafka.connect.json.JsonConverter"
{% endhighlight %}

--

[View the full `docker-compose.yml` settings for Kafka Connect](https://github.com/lombardo-chcg/kafka-local-stack/blob/ch3/docker-compose.yml#L71)
