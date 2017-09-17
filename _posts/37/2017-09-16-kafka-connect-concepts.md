---
layout: post
title:  "kafka connect concepts"
date:   2017-09-16 18:44:19
categories: tools
excerpt: "understanding the pieces of Kafka Connect"
tags:
  - kafka
  - apache
  - streaming
---


Here is some content gathered from [the Kafka Connect docs](https://docs.confluent.io/current/connect/concepts.html) to help me remember how Kafka Connect works.

#### *connectors*
* a connector instance is a logical job that is responsible for managing the copying of data between Kafka and another system
* connector instances can monitor the source or sink system to which they are assigned, and update tasks accordingly

#### *tasks*
* Each connector instance assigns work to a group of tasks - the number of tasks is provided in the connector definition.
* this is a way to distribute the work
* Task state is stored in Kafka in special topics (`config.storage.topic` and `status.storage.topic`)

Here's a basic workflow:

1. Connector 'A' is created to copy data from a Kafka topic to Elasticsearch.  
2. The user specifies 2 maximum tasks for this connector.
3. The Kafka topic has 4 partitions
4. Connector 'A' creates Task 1 and assigns it partitions 1 and 2.  
5. Task 2 is assigned partitions 3 and 4.

Now come the workers.

#### *workers*
* when we start an "instance" of Kafka Connect, what we are doing is starting up a worker
* workers represent the JVM processes where the movement of data is done
* workers are passed [configuration](/tools/2017/09/03/kafka-connect-101.html)
* a Kafka Connect worker cluster can be set up consisting of multiple workers.  The Workers are all given the same `group.id`, which is essentially a Kafka consumer group, which allows them to coordinate, handle failures, and more.
