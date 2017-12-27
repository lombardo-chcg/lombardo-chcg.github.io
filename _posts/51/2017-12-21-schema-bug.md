---
layout: post
title:  "debugging the confluent platform"
date:   2017-12-21 10:47:07
categories: tools
excerpt: "getting past a tricky error with kafka connect and the schema registry"
tags:
  - confluent
  - avro
  - schema
  - registry
  - kafka
  - connect
---

### Scenario
Running the Confluent Schema Registry and Kafka Connect when this error appears:

{% highlight bash %}
org.apache.kafka.common.errors.SerializationException: Error retrieving Avro schema
io.confluent.kafka.schemaregistry.client.rest.exceptions.RestClientException: Subject not found. error code: 40401
{% endhighlight %}

### Reason
My Kafka Connector config had the following converter settings:
{% highlight bash %}
"key.converter": "io.confluent.connect.avro.AvroConverter"
"value.converter": "io.confluent.connect.avro.AvroConverter"
{% endhighlight %}

However, the producer on the topic was of type `[String, GenericRecord]`, meaning the `key` for each message was a RAW string, not an Avro-schema-backed message of type string.  The `value` of the message was an Avro `GenericRecord`.

The Connector was attempting to reach the Schema Registry to pull down the schema for the message key.  The schema ID is located in the  [`magic bytes`](https://docs.confluent.io/current/schema-registry/docs/serializer-formatter.html#wire-format) of a Kafka message per the Confluent docs.  The issue is the message I was sending was a byte array serialized RAW string not an Avro record.  Therefore, the Connector choked on the conversion with an unhelpful message. 

The solution is to change the key convertor to `StringConverter` instead of `AvroConverter`:

{% highlight bash %}
"key.converter": "org.apache.kafka.connect.storage.StringConverter"
"value.converter": "io.confluent.connect.avro.AvroConverter"
{% endhighlight %}
