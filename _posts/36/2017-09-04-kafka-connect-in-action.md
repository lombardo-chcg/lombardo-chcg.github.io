---
layout: post
title:  "kafka connect in action"
date:   2017-09-04 09:04:08
categories: tools
excerpt: "setting up a basic kafka connector that writes to a local file"
tags:
  - kafka
  - apache
  - docker
  - confluent
---

[Last time](/tools/2017/09/03/kafka-connect-101.html) we saw the basic config settings needed to stand up an instance of Kafka Connect.  Now let's see it in action.

The goal:
1. Produce messages to a `readings` topic
2. Set up Kafka Connect to consume from this topic and write to a local file


[**Reference Repo: https://github.com/lombardo-chcg/kafka-local-stack/tree/ch3**](https://github.com/lombardo-chcg/kafka-local-stack/tree/ch3)

--

#### Step one: Start containers
{% highlight bash %}
git clone https://github.com/lombardo-chcg/kafka-local-stack.git
cd kafka-local-stack
git checkout ch3
docker-compose up -d
{% endhighlight %}

1) Note that the Kafka Connect container [has a volume mounted](https://github.com/lombardo-chcg/kafka-local-stack/blob/ch3/docker-compose.yml#L100) consisting of a empty text file.  This is the "sink" Kafak Connect will use in our example.  In the real world this would be a database like Elasticsearch.
{% highlight yml %}
volumes:
  - ./readings:/tmp/readings
{% endhighlight %}

2) Also note that we are using the basic `StringConverter` to interface Kafka Connect to Kafka.

--

#### Step two: create Kafka Connect job.  

This is where Kafka Connect shows its worth: deploying a new connector with zero coding.  We will be using the official `FileStreamSinkConnector` that has been created by the Kafka Connect team and passing it a configuration.

We must send a JSON payload to a rest endpoint to create this new connector.  Make this request using Postman:

`POST http://localhost:8083/connectors`

{% highlight json %}
{
	"name": "readings-sink",
	"config": {
		"connector.class":"org.apache.kafka.connect.file.FileStreamSinkConnector",
		"tasks.max":"1",
		"topics":"readings",
		"file": "/tmp/readings/data.txt"
	}
}
{% endhighlight %}

Info on our new connector is available via the rest api:
* `http://localhost:8083/connectors/readings-sink`
* `http://localhost:8083/connectors/readings-sink/status`

--

#### Step three: publish messages to `readings` topic

The demo docker network contains a homemade "rest_producer" which takes a JSON payload and publishes it to Kafka as a `ProducerRecord(String topic, String key, String value)`

Sample message:

`POST http://localhost:8080/messages`

{% highlight json %}
{
  "topic": "readings",
  "key": "52",
  "content": "looking at the trees"
}
{% endhighlight %}

We'll use a bash script which sends messages to our `rest_producer` on a loop:
{% highlight bash %}
./create_readings.sh
{% endhighlight %}

Reminder: we are using the `StringConverter` to interface Kafka Connect to Kafka.  This is because our `rest_producer`, while accepting JSON, is presently publishing to Kafka using the basic `String` message format.


--

#### Step four: glory

In a separate window, `tail` the local file to where Kafka Connect is writing the data:
{% highlight bash %}
tail -f readings/data.txt
{% endhighlight %}
