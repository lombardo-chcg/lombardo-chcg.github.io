---
layout: post
title:  "exactly once"
date:   2017-11-06 21:51:37
categories: tools
excerpt: "Apache Kafka's approach to an old problem"
tags:
  - streaming
  - kafka
  - java
---

Some notes I took while watching [*Introducing Exactly Once Semantics*](https://www.confluent.io/thank-you/introducing-exactly-semantics-apache-kafka/) talk, presented by Apurva Mehta of Confluent.

#### 1) Idempotent Producer
* `producer.send` will always lead to one copy in the log
* not in the consumer - you can still consume a message multiple times

Done with configuration:
{% highlight bash %}
enable.idempotence = true
max.inflight.requests.per.connection = 1
acks = all
retries = MAX_INT
{% endhighlight %}

How is this done?  Metadata on each message.
* producer ID (assigned by the broker)
* sequence ID for the message - producer and topic leader agree.  valid for the producer session only.
* this metadata is kept in the log (enabling resilience around changing leaders for example)
* If producer doesn't get an ack, it resends the message.  If broker has already processed the message, it just sends an `ack` without writing it to the log

#### 2) Transaction API

New components in the Kafka ecosystem

* Transaction coordinator - maintains transaction state on a per-producer basis.  Runs within broker.  
* Transaction log - persists the state

Producer side:
{% highlight java %}
producer.initTransactions()
  // register transactional.id with the transaction coordinator component
  // resolve outstanding transactions before accepting new messages
  // done once when producer comes online
producer.beginTransaction()
  // a producer can be part of only one transaction at a time   
producer.send()
  // partitions are registered with the Transaction coordinator
  // data is written to the log as usual
producer.commitTransaction()
  // two phase commit - 1) producer sends a commit RPC to the Transaction coordinator  
  // 2) Transaction coordinator writes transaction "commit markers" to the data logs
{% endhighlight %}

Consumers can `read_committed` or `read_uncommitted` which is a configuration

Messages are still in offset order.  Transaction order can differ but is invisible to consumers.
