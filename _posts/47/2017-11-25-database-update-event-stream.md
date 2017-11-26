---
layout: post
title:  "kafka connect in action, part 3"
date:   2017-11-25 19:44:38
categories: tools
excerpt: "streaming updates from a Postgres source database thru a data pipeline"
tags:
  - apache
  - kafka
  - confluent
  - streaming
  - zookeeper
  - docker
---

[*make sure to follow this example first to set up a docker environment for the example*](/tools/2017/11/24/kafka-connect-in-action,-part-2.html)

--

## High Level Overview

* Setup Kafka Connect so that updates to existing rows in a Postgres `source` table are put into a topic
* (aka set up an event stream representing changes to a PG table)
* Use Kafka Connect to write that PG data to a local `sink`

## Start Containers

[*i repeat...make sure to follow this example for the docker compose config*](/tools/2017/11/24/kafka-connect-in-action,-part-2.html)


{% highlight bash %}
docker-compose up -d
{% endhighlight %}

## Create a new Postgres Table with timestamp trigger

We will need to set up a Postgres table that automatically updates a `last_modified` column with the current timestamp every time a change is made.

Then, we will tell our Kafka Connect Connector to pay attention to that specific column.

Enter a `psql` session inside the running PG container:
{% highlight bash %}
docker exec -it postgres psql -U postgres
{% endhighlight %}

inside the `psql` session:
{% highlight sql %}
CREATE DATABASE streaming_example;
\connect streaming_example

CREATE TABLE streaming_update_table (
  id serial PRIMARY KEY,
  data varchar(256) NOT NULL,
  is_soft_deleted boolean default false,
  create_date timestamp NOT NULL default now(),
  last_updated timestamp NOT NULL default now()
);

-- setup a function to update the last_updated column automatically
CREATE OR REPLACE FUNCTION update_last_updated_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_updated = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- apply the function as a trigger
CREATE TRIGGER update_last_updated_column
BEFORE UPDATE ON streaming_update_table
FOR EACH ROW EXECUTE PROCEDURE update_last_updated_column();

-- start off with a sample record
INSERT INTO streaming_update_table (data) values ('test data');
{% endhighlight %}


## Setup Kafka Source Connector for our new table

Here we set the JDBC connector `mode` as `timestamp+incrementing`.  More details here: [https://docs.confluent.io/current/connect/connect-jdbc/docs/source_connector.html#incremental-query-modes](https://docs.confluent.io/current/connect/connect-jdbc/docs/source_connector.html#incremental-query-modes)

Take note of our key values: `connection.url`, `timestamp.column.name`, `incrementing.column.name` which contain data specific to this example.

`POST` [`http://localhost:8083/connectors`](http://localhost:8083/connectors)
{% highlight json %}
{
  "name": "pg.source.connector",
  "config": {
  	"connector.class":"io.confluent.connect.jdbc.JdbcSourceConnector",
  	"tasks.max":"1",
  	"connection.url":"jdbc:postgresql://postgres:5432/streaming_example",
  	"connection.user": "postgres",
  	"connection.password":"postgres",
  	"mode": "timestamp+incrementing",
  	"timestamp.column.name": "last_updated",
  	"incrementing.column.name": "id",
  	"topic.prefix": "postgres.with.timestamps."
  }
}
{% endhighlight %}

## Confirm new topic created
{% highlight bash %}
kafka-topics --zookeeper localhost:2181 --list

# ...
# postgres.with.timestamps.streaming_update_table
{% endhighlight %}

## Setup sink connector

First, let's set up a "sink" file and tail it (recall that the file location directory specified is mounted in the Kafka Connect container via the `docker-compose` file):

{% highlight bash %}
touch data/streaming_output.txt
tail -f data/streaming_output.txt
{% endhighlight %}

Here's the Sink Connector config which needs to be posted to Kafka Connect:

`POST` [`http://localhost:8083/connectors`](http://localhost:8083/connectors)
{% highlight json %}
{
  "name":"streaming.updates.sink",
  "config":{
    "connector.class":"org.apache.kafka.connect.file.FileStreamSinkConnector",
    "tasks.max":"1",
    "topics": "postgres.with.timestamps.streaming_update_table",
    "file":"/tmp/data/streaming_output.txt"
  }
}
{% endhighlight %}

After a few seconds the record should show up in the window where you ran `tail -f data/streaming_output.txt`

## Profit

Now we can make updates to our existing Postgres records and the updates will "stream" out of the database thru Kafka Connect and into a topic.  

{% highlight sql %}
UPDATE streaming_update_table
SET data = 'some new data'
WHERE id = 1;
{% endhighlight %}

The record should come across to our file!

Use case?  We can store all the database changes as they happen, and then play them back later - i.e. for disaster recovery.  This is an alternative to say, taking a whole snapshot of the database.

We can also soft delete and watch the update come through the data pipeline and into our sink:

{% highlight sql %}
UPDATE streaming_update_table
SET is_soft_deleted = true
WHERE id = 1;
{% endhighlight %}

Note that if we issue an acutal SQL `DELETE` command into our `psql` session, that update does not come across the topic.  For that we would apparently need some more specialized "CDC" or Change Data Capture software.  I'll save that for another time.  Also in my experience it is farily uncommon to actually "DELETE" data from a database, more common to soft-delete it using a boolean flag.
