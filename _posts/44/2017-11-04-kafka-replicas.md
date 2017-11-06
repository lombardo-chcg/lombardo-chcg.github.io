---
layout: post
title:  "kafka monitoring"
date:   2017-11-04 17:39:26
categories: tools
excerpt: "tips for keeping an eye on Apache Kafka"
tags:
  -
---

Some notes I jotted down while watching [this presentation](http://videos.confluent.io/watch/Y7q2zGJqow599bZghn2r4m) by Gwen Shapira from Confluent. 

### Kafka Metrics

#### Cluster Health
1. At a minimum: are the brokers healthy?
2. A good "check engine light" is having under-replicated partitions.  this issue can be related to many issues within the system.  For example:
* Broker issues: broker down, broker has a problem (i.e. network issue, resource problem, misconfiguration)
* Systemwide issues: brokers are out of balance (i.e. one broker is the leader of too many topics and is doing too much work)
3. Capacity monitoring is important.  Adding brokers means moving partitions which means network traffic, CPU usage and disk I/O.  This can be transparent if done with enough headroom (below 70%)

#### The basic Monitoring technique
* Count messages produced
* Count messages consumed
* Check timestamps

This basic technique leads to metrics such as:
* under-consumption (consumer is missing messages)
* over-consumption (consumer reading messages twice) which can lead to latency over time
* consumers are falling behind.  consumers far behind force Kafka to read from disk instead of memory - this can impact the speed of the whole system

#### Kafka Request Lifecycle
* Kafka receives request
* request sent to the request queue
* request picked up by i/o thread which does writing or reading of data
* wait for remote response - wait for other brokers to respond (i.e. acks)
* create response
* send to response queue
* network thread picks up response and sends out the message to the OS for network dispatch
