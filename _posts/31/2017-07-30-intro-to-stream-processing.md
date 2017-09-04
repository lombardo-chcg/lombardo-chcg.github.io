---
layout: post
title:  "intro to stream processing"
date:   2017-07-30 22:08:40
categories: tools
excerpt: "turning my sbt starter pack into a kafka stream processor app"
tags:
  - kafka
  - docker
  - scala
  - sbt
---

I started out today wanting to learn more about [Kafka Streams](http://docs.confluent.io/current/streams/index.html), which is an open-source library that enables rapid application development over an Apache Kafka infrastructure, by handling the plumbing part of the equation.

After poking around a bit I thought I would benefit more from actually building some of the plumbing myself, just to learn how all the pieces fit together.

So I ended up building on my [sbt starter pack](/tools/2017/07/29/sbt-basics.html) to make a basic Kafka stream processing app.

Here's the code: [https://github.com/lombardo-chcg/kafka-scala-consumer](https://github.com/lombardo-chcg/kafka-scala-consumer)


I added the app to my growing [Kafka/Docker stack](https://github.com/lombardo-chcg/kafka-local-stack/tree/ch2), and here's a mini-workflow to show how the pieces connect:

1.  Kick off a shell script that publishes a stream of mock "readings" using random numbers
2.  The script sends http requests to my [rest producer](/exploration/2017/07/26/keys-&-case-classes.html) app as JSON.  The app publishes the JSON to a Kafka topic
3. The new service consumes from that topic, taking each record and doing a basic "map" operation over it.  (honestly it just takes the "reading", doubles it, and prints out the result to standard out.  but *technically* that is real time stream processing!!)

Try it out! Download the docker compose file here:
[https://github.com/lombardo-chcg/kafka-local-stack/tree/ch2](https://github.com/lombardo-chcg/kafka-local-stack/tree/ch2)

Open 2 terminal sessions.

Session 1:
```
# start containers
docker-compose up -d

# kick off the stream of input
./create_readings.sh
```

Session 2:
```
# watch the streaming output
docker logs -f basic_stream_processor
```

This is the most ridiculously complex Hello World app in history...but I had some fun with it.
