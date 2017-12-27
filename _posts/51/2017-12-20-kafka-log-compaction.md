---
layout: post
title:  "kafka log compaction"
date:   2017-12-20 16:41:59
categories: tools
excerpt: "dockerized example of using log compaction to create a distributed cache with Apache Kafka"
tags:
  - apache
  - kafka
  - state
  - zookeeper
  - cache
  - distributed
  - docker
---

ZooKeeper's `zNode`s provide a great way to cache a small cache across multiple running instances of the same application.

Let's look into using Kafka's Log Compaction feature for the same purpose.

Here's some official reading on the subject: [https://kafka.apache.org/documentation/#compaction](https://kafka.apache.org/documentation/#compaction).

And here's a `docker-compose` file to get up-and-running quickly with the Confluent 4.0 platform which is the latest as of this writing.

* Copy the following content into a file called `docker-compose.yml`
* execute the following command from the same directory: `docker-compose up -d`

{% highlight yaml %}
version: "2"

services:
  zookeeper:
    container_name: zookeeper
    image: confluentinc/cp-zookeeper:4.0.0
    ports:
      - "2181:2181"
    hostname: zookeeper
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181

  kafka:
    container_name: kafka
    image: confluentinc/cp-kafka:4.0.0
    hostname: kafka
    ports:
      - "9092"
      - "9091:9091"
    links:
      - zookeeper
    depends_on:
      - zookeeper
    environment:
      ADVERTISED_HOST_NAME: "kafka"
      KAFKA_INTER_BROKER_LISTENER_NAME: "PLAINTEXT"
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: "EXTERNAL:PLAINTEXT,PLAINTEXT:PLAINTEXT"
      KAFKA_ADVERTISED_LISTENERS: "EXTERNAL://localhost:9091,PLAINTEXT://kafka:9092"
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_DELETE_RETENTION_MS: 5000
      KAFKA_LOG_CLEANER_DELETE_RETENTION_MS: 5000
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1      

  schema_registry:
    container_name: schema_registry
    image: confluentinc/cp-schema-registry:4.0.0
    ports:
      - "8081:8081"
    links:
      - zookeeper
      - kafka
    depends_on:
      - zookeeper
      - kafka
    environment:
      SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL: zookeeper:2181
      SCHEMA_REGISTRY_HOST_NAME: schema_registry

  kafka_connect:
    container_name: kafka_connect
    image: confluentinc/cp-kafka-connect:4.0.0
    ports:
      - "8083:8083"
    links:
      - zookeeper
      - kafka
      - schema_registry
    depends_on:
      - zookeeper
      - kafka
      - schema_registry
    environment:
      # networking
      CONNECT_BOOTSTRAP_SERVERS: "kafka:9092"
      CONNECT_REST_ADVERTISED_HOST_NAME: "kafka_connect"
      CONNECT_REST_PORT: "8083"
      # kafka
      CONNECT_GROUP_ID: "kc"
      CONNECT_CONFIG_STORAGE_TOPIC: "kc-config"
      CONNECT_OFFSET_STORAGE_TOPIC: "kc-offset"
      CONNECT_STATUS_STORAGE_TOPIC: "kc-status"
      CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR: 1
      CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR: 1
      CONNECT_STATUS_STORAGE_REPLICATION_FACTOR: 1
      # convertors
      CONNECT_KEY_CONVERTER: "io.confluent.connect.avro.AvroConverter"
      CONNECT_VALUE_CONVERTER: "io.confluent.connect.avro.AvroConverter"
      CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL: "http://schema_registry:8081"
      CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL: "http://schema_registry:8081"
      CONNECT_INTERNAL_KEY_CONVERTER: "org.apache.kafka.connect.json.JsonConverter"
      CONNECT_INTERNAL_VALUE_CONVERTER: "org.apache.kafka.connect.json.JsonConverter"
{% endhighlight %}

*Note: this docker-compose file using some nifty settings that enable traffic to Kafka from inside and outside the Docker network. *

Now let's create a compacted topic.  Here I am fiddling with values such as `delete.retention.ms` and `min.cleanable.dirty.ratio` just to prove the point for the example.  For production these values would have to be tuned.

Execute this from the terminal:
{% highlight bash %}
kafka-topics --zookeeper localhost:2181 \
  --create --topic cache.topic \
  --config "cleanup.policy=compact" \
  --config "delete.retention.ms=100" \
  --config "segment.ms=100" \
  --config "min.cleanable.dirty.ratio=0.01" \
  --partitions 1 \
  --replication-factor 1
{% endhighlight %}

Now lets send a few messages to the topic *with the same key for each message*.

Read more here about how a Kafka background process determines how it removes records with dup'ed keys from the log:

> Log compaction is handled by the log cleaner, a pool of background threads that recopy log segment files, removing records whose key appears in the head of the log

> [https://kafka.apache.org/documentation/#design_compactiondetails](https://kafka.apache.org/documentation/#design_compactiondetails)

This requires us to use a pass special properties using the `-property` flag in the Kafka Console Producer
* `parse.key=true`
* `key.separator=:`

{% highlight bash %}
for i in $(seq 0 10); do \
  echo "sameKey123:differentMessage$i" | kafka-console-producer \
  --broker-list localhost:9091 \
  --topic cache.topic \
  --property "parse.key=true" \
  --property "key.separator=:"; \
done

# output doesn't print but messages will be: `differentMessage1 .. differentMessage10`
{% endhighlight %}

Now let's check out the results:
{% highlight bash %}
kafka-console-consumer --bootstrap-server localhost:9091 \
  --topic cache.topic \
  --property print.key=true \
  --property key.separator=" : " \
  --from-beginning
{% endhighlight %}

I see:
{% highlight bash %}
sameKey123 : differentMessage9
sameKey123 : differentMessage10
{% endhighlight %}

Our bash `for` loop ran 10 times but only entries `9` and `10` are present on the topic.  Messages `1` - `8` have been cleaned up by the log cleaner.

I was expected to see ONLY the latest messages.  (not the last two)

Well, this is only the "hello world" of Log Compaction and the settings would need tuning based on more research and testing to ensure a reliable cache.

But my reaction for now: pause and think that each application using a compacted Kafka topic as a cache may encounter a situation where they read the cache and see the same key twice (this is what happpened in the example above).  

But that is topic-tuning and some unit tests away.  Very cool to see the potential of using Kafka as a distributed systems cache.

*unanswered: zookeeper provides `reentrant locking` on zNodes, preventing cache-update race conditions.  How would the group arrive at a consensus with no guarantee of resource locking?*
