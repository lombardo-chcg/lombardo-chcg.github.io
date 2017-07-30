---
layout: post
title:  "rethinking data streams"
date:   2017-07-29 23:38:08
categories: wisdom
excerpt: "a new perspective on data events"
tags:
  - kafka
  - database
---

This week I heard two separate conference talks mention the same concept.  Got me thinking and I wanted to capture it.

First, at the AWS Chicago Summit, John Bennett from Netflix mentioned almost as an afterthought that updates to a database over time are really just an event stream.  I can't recall the context but that thought really hit me over the head as something I already knew, but just didn't realize.  (the deepest insights are usually of this type, similar to a curtain being drawn back and revealing something that was there the whole time)

Then, today I was [watching a talk](https://www.youtube.com/watch?v=zVK12q9PpQg) given by Jay Kreps, one of the founders of Confluent and of Apache Kafka, and he mentioned a similar idea.  He went much deeper into the concept of a database table as an event stream.  The gist I took away was, a table is a snapshot of data that changes over time as CRUD operations are performed.  So, conceptually, the database table as viewed by a user can be understood to be the latest in a sequence of tables.  

Taking it further, the sequence of tables can be snapshots of the entire table over time, or, much more simply, it can be just the sequence of "events" that changed the state of the table.  With knowledge of this sequence, the entire table could be "replayed" and thus recreated.  This could be used as a clever mode of database backup.

Apparently this is known as the "table/stream duality".   And this type of thinking is at the heart of log-based "streaming platforms" like Kafka and Kinesis.

As we move away from the world of "big data" and its batch and micro-batch processing, and into the world of "real time" data streaming with real time processing, it makes sense to think this way.

So...where else could this event stream logic be applied?
* git
* application/server logs
* network activity log
