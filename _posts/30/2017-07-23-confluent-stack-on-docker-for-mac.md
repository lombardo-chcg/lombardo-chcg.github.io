---
layout: post
title:  "kafka stack on docker for mac"
date:   2017-07-23 19:38:17
categories: tools
excerpt: "setting up a local kafka sandbox for experiments"
tags:
  - zookeeper
  - apache
  - stream
---

I'm familiar with Apache Kafka in a general sense but I am looking to dive deeper.  I decided to put together a quick `docker-compose.yml` file to get up and running quickly.  (file is at the end of this post)

In the `compose` file, there's even a container just for the Kafka CLI tools.  Normally, we'd be able to set the `KAFKA_ADVERTISED_LISTENERS` variable to be `localhost` and we could use the Kafka CLI from a regular terminal session.  I am planning to grow this stack to include a few more components, and I want to keep all direct Kafka connectivity inside the Docker network.

Here's how to use it.  First copy the `yml` file at the bottom of this post to your local system.

Then:

{% highlight bash %}
docker-compose up -d

docker exec -it kafka-cli bash

# now inside the CLI container
./kafka-console-producer.sh --broker-list kafka:9092 --topic demo
# start typing messages, pressing enter after each
# these will be sent to kafka under the topic name "demo"

# now open another terminal:
docker exec -it kafka-cli bash
./kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic demo --from-beginning
# your previous messages should appear here!
# type some more messages in the producer console..
# they should continue to appear in this terminal
{% endhighlight %}

`docker-compose.yml`
{% highlight yaml %}
version: "2"

services:
  zookeeper:
    container_name: zookeeper
    image: confluentinc/cp-zookeeper:3.2.1
    ports:
      - "2181:2181"
    hostname: zookeeper
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181

  kafka:
    container_name: kafka
    image: confluentinc/cp-kafka:3.2.1
    ports:
      - "9092:9092"
    links:
      - zookeeper
    depends_on:
      - zookeeper
    hostname: kafka
    environment:
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      ADVERTISED_HOST_NAME: kafka

  schema_registry:
    container_name: schema_registry
    image: confluentinc/cp-schema-registry:3.2.1
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

  rest_proxy:
    container_name: rest_proxy
    image: confluentinc/cp-kafka-rest:3.2.1
    ports:
      - "8082:8082"
    links:
      - zookeeper
      - kafka
      - schema_registry
    depends_on:
      - zookeeper
      - kafka
      - schema_registry
    environment:
      KAFKA_REST_HOST_NAME: rest_proxy
      KAFKA_REST_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_REST_SCHEMA_REGISTRY_URL: http://schema_registry:8081

  kafka-cli:
    container_name: kafka-cli
    image: taion809/kafka-cli
    working_dir: /opt/kafka/bin
    # dummy command just to give the container a PID 1 and keep it running
    command: "tail -f /var/log/bootstrap.log > /dev/null 2>&1"
    links:
      - kafka
      - zookeeper
{% endhighlight %}  
