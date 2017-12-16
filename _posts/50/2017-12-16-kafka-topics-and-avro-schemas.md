---
layout: post
title:  "kafka topics and avro schemas"
date:   2017-12-16 14:03:06
categories: tools
excerpt: "validating an assumption around schema-backed Kafka topics"
tags:
  - apache
  - avro
  - kafka
  - schema
  - streaming
---

When I started working with Kafka, I was under the assumption that a topic is able to be "schema-backed" meaning that any messages written to that topic have to use the same avro schema.  

Looks like that assumption is not valid.

Steps to validate:
* setup the source connector as described in this example: [kafka connect in action](/tools/2017/11/24/kafka-connect-in-action,-part-2.html)
* setup a basic console producer and fire off some "strings" to the topic:
{% highlight bash %}
kafka-console-producer --broker-list localhost:9091 --topic postgres.sourced.greetings

# just start typing and hitting enter, each line is a message
{% endhighlight %}

* consume the messages, which shows there is Avro and strings mixed in the same topic:
{% highlight bash %}
kafka-console-consumer --bootstrap-server localhost:9091 --topic postgres.sourced.greetings --from-beginning

EnglishHello World�Ѳ��X
SpanishHola Mundo�Ѳ��X

French Bonjour le monde�Ѳ��X
ItalianCiao mondo�Ѳ��X
hello world
testing
123
{% endhighlight %}

* follow the steps from the [kafka connect in action](/tools/2017/11/24/kafka-connect-in-action,-part-2.html) example to start the sink connector.
* `curl localhost:8083/connectors/greetings.sink/status | jq -r '.tasks | map(.trace)'` shows the consumer task has failed with an Avro serdes issue.

So, the assumption has been BUSTED, and it seems can produces can shove random bytes into a topic which may break a downstream consumer.  
