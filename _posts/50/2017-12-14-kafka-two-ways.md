---
layout: post
title:  "kafka two ways"
date:   2017-12-14 18:47:10
categories: tools
excerpt: "using kafka for event streaming and as a data store"
tags:
  - apache
  - kafka
  - streaming
  - ZooKeeper
  - cache  
---

The most common use case for Kafka is as a source for real time data "streaming", where incoming messages are appended to a log and consumers can read from the log at their preferred pace.  

Another use case is allowed by the concept of "compacted topics".  From the [docs](https://kafka.apache.org/documentation/#compaction):

> Log compaction ensures that Kafka will always retain at least the last known value for each message key within the log of data for a single topic partition.

The example on that page is great and I encourage you to read thru the section.  My takeaway is that a distributed application that needs to maintain a cache can do so using a compacted topic.  As instances of the application come online, they can consume the entire compacted topic and then be up to date on the state of the world.  As each application publishes a change that data is read by all the other instances who are consuming the topic.  

The issue of two instances operating on the same cache entry may become a big problem in this situation (as with any distributed system) but I would reach for ZooKeeper as the tool to solve that job.
