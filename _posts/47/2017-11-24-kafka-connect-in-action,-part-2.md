---
layout: post
title:  "kafka connect in action, part 2"
date:   2017-11-24 17:00:42
categories: tools
excerpt: "setting up a basic data pipeline using Postgres, a JDBC Source Connector and a local file sink"
tags:
  - apache
  - kafka
  - confluent
  - streaming
  - zookeeper
  - docker
---

Up til now, I have focused mainly on Kafka Connect's Sinks connectors.  Lets's set up a quick data pipeline to explore a Source connectors.  

For the example I'll be using a pre-populated Postgres Docker image [from a previous post](/web-dev/2017/04/08/scalatra+docker-(part-6).html):

* [https://hub.docker.com/r/lombardo/postgres-scrabble-helper/](https://hub.docker.com/r/lombardo/postgres-scrabble-helper/)

## High Level Overview

* Use Kafka Connect to read data from a Postgres DB `source` that has multiple tables into distinct kafka topics   
* Use Kafka Connect to write that PG data to a `sink` (we'll use file sink in this example)

## Setup

{% highlight bash %}
mkdir kafka-connect-source-example
cd kafka-connect-source-example/
mkdir data
touch data/data.txt
touch docker-compose.yml
{% endhighlight %}

inside `docker-compose.yml`:

###### (yes, I know I am many versions behind on the confluent platform @3.2.1.  I'm more interested in the concepts... I'll save the upgrade for another time.)

{% highlight yml %}
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
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1

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

  kafka_connect:
    container_name: kafka_connect
    image: confluentinc/cp-kafka-connect:3.2.1
    ports:
      - "8083:8083"
    links:
      - zookeeper
      - kafka
      - schema_registry
      - postgres
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
      # convertors
      CONNECT_KEY_CONVERTER: "io.confluent.connect.avro.AvroConverter"
      CONNECT_VALUE_CONVERTER: "io.confluent.connect.avro.AvroConverter"
      CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL: "http://schema_registry:8081"
      CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL: "http://schema_registry:8081"
      CONNECT_INTERNAL_KEY_CONVERTER: "org.apache.kafka.connect.json.JsonConverter"
      CONNECT_INTERNAL_VALUE_CONVERTER: "org.apache.kafka.connect.json.JsonConverter"
    volumes:
      - ./data:/tmp/data

  postgres:
    image: lombardo/postgres-scrabble-helper:latest
    container_name: postgres
    ports:
      - "5431:5432"
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=scrabble_helper
{% endhighlight %}


## Start Your Containers

{% highlight bash %}
docker-compose up -d
{% endhighlight %}

## Source Connector

Let's confirm data in postgres:
{% highlight bash %}
docker exec -it postgres psql -U postgres

# psql session

\connect scrabble_helper
\d
{% endhighlight %}

We see `greetings` and `words` tables (along with the `*_id_seq` sequence tables that PG auto-creates)

Now we need to setup a Kafa Connector to read from these tables.

The config is pretty standard - I copped mine from the Confluent tutorial. but there are a few modifications for our use case.  

`POST` [`localhost:8083/connectors`](http://localhost:8083/connectors)

{% highlight json %}
{
   "name":"postgres.connector",
   "config":{
      "connector.class":"io.confluent.connect.jdbc.JdbcSourceConnector",
      "tasks.max":"1",
      "connection.url":"jdbc:postgresql://postgres:5432/scrabble_helper",
      "connection.user":"postgres",
      "connection.password":"postgres",
      "mode":"incrementing",
      "incrementing.column.name":"id",
      "topic.prefix":"postgres.sourced."
   }
}
{% endhighlight %}
##### (note the `connection.url` which specifies a postgres driver type, the PG address on the Docker network, and the name of our database)

Let's check ZooKeeper to see if our new topics exist

{% highlight bash %}
# OSX TIP: `brew install kafka` for quick access to the cli.

kafka-topics --zookeeper localhost:2181 --list

# ...
# postgres.sourced.greetings
# postgres.sourced.words
{% endhighlight %}


Our new topics are there.  Let's consume from one to be sure it has messages:

{% highlight bash %}
kafka-console-consumer --bootstrap-server localhost:9091 --topic postgres.sourced.greetings --from-beginning
{% endhighlight %}

There should be 4 messages.  The text will be jumbled because we are in Avro format.

## Schemas

Speaking of Avro, let's check the schema registry.

[`localhost:8081/subjects`](http://localhost:8081/subjects)

There's the auto-generated schemas for our PG Tables.  PG makes this easy as each column provides a type and the data structure is inherently flat.

Here's the inferred schema for the Greetings Table:  [`http://localhost:8081/subjects/postgres.sourced.greetings-value/versions/latest`](http://localhost:8081/subjects/postgres.sourced.greetings-value/versions/latest)

{% highlight json %}
{
   "type":"record",
   "name":"greetings",
   "fields":[
      {
         "name":"id",
         "type":"int"
      },
      {
         "name":"language",
         "type":"string"
      },
      {
         "name":"content",
         "type":"string"
      },
      {
         "name":"create_date",
         "type":{
            "type":"long",
            "connect.version":1,
            "connect.name":"org.apache.kafka.connect.data.Timestamp",
            "logicalType":"timestamp-millis"
         }
      }
   ],
   "connect.name":"greetings"
}
{% endhighlight %}


There's also a `connect.name` field that seems to have been added automatically as metadata which is interesting.


Ok, so now our data is in Kafka and conforms to a schema.  Let's set up a sink.

## Sink

We'll use the basic Apache `FileStreamSinkConnector` config for a local File Connector:

`POST` [`localhost:8083/connectors`](http://localhost:8083/connectors)

{% highlight json %}
{
   "name":"greetings.sink",
   "config":{
      "connector.class":"org.apache.kafka.connect.file.FileStreamSinkConnector",
      "tasks.max":"1",
      "topics":"postgres.sourced.greetings",
      "file":"/tmp/data/data.txt"
   }
}
{% endhighlight %}

In your terminal:

{% highlight bash %}
tail -f data/data.txt
{% endhighlight %}

There we should see our 4 records which have completed their journey from PG to a local Sink.


--


Let's watch it in real time.  In one terminal pane, `tail -f data/data.txt`

In another,

{% highlight bash %}
docker exec -it postgres psql -U postgres
\connect scrabble_helper
insert into greetings (language, content) values ('Czech', 'Ahoj');
{% endhighlight %}

Records are now showing up in the file moments after being added to Postgres.  

A basic but real-time data pipeline!

--

Note that `delete from greetings where id=3;` does not show up in the topic and therefore the sink.  so we are not streaming updates from the database, merely appends.  I may explore another type of `mode` for this Kafka Connect JDBC connector at a later time which may allow for streaming updates.
