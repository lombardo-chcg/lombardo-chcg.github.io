---
layout: post
title:  "connection pooling"
date:   2017-04-11 21:29:49
categories: databases
excerpt: "sharing database connections with postgres"
tags:
  - postgres
  - sql
  - jdbc
  - java
---

As part of my ongoing [scalatra+docker](/search?term=scalatra) series I am diving into hand-rolling database connections for the Scalatra app.  In the [last post](/web-dev/2017/04/08/scalatra+docker(+postgres)-(part-7).html) I hacked my way to an MPV implementation where each database interaction required opening a new connection to the db, then closing it when completed.  In theory this is a solid approach but it is far too inefficient for practical use.  So I have started to research Connection Pooling.  This is something natively supported by my chosen db, Postgres, so that makes it easy to implement.

I'll follow up with a walk-thru post at a later time, but the basic gist is to create an open Connection Pool when the application boots up, and a Class or Object to manage the pool.  Then, provide a stable API to other application components allowing them to "request" db connections when needed and "return" them when complete.  

Its easy to sense the efficiencies gained by having a standing pool available for sharing, and not having to actually open and close connections on each request.

Here's the bare-bones JDBC implementation I am going to follow in creating my connection pool: [https://jdbc.postgresql.org/documentation/head/ds-ds.html](https://jdbc.postgresql.org/documentation/head/ds-ds.html)

Stay tuned for the results.
