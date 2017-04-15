---
layout: post
title:  "implementing a postgres connection pool"
date:   2017-04-14 21:49:18
categories: databases
excerpt: "creating a jdbc connection pool for a scala app"
tags:
  - scalatra
  - jvm
  - java
  - jdbc
  - postgres
---

[A few posts ago](/databases/2017/04/11/connection-pooling.html) I mentioned my interest in implementing a database connection pool for my ongoing [Scalatra-Docker-Postgres](/search?term=scalatra) series.  

Here's how I ended up implementing it.  I decided to create a singleton Scala `object` called `dbConnector` which creates and maintains the connection pool.  `dbConnector` provides an interface for other classes to request a connection and then return it when completed: `getConnection` and `close`

I also added a `testConnection` method which is called when the connection pool is established.  This will produce a nice output that shows a successful DB connection.

Here's how it looks in Scala:

{% highlight scala %}
package com.lombardo.app.connectors

import java.sql._
import org.postgresql.ds.PGPoolingDataSource
import org.slf4j.LoggerFactory

object dbConnector {
  val logger =  LoggerFactory.getLogger(getClass)
  val postgresHost = "dockerhost:5431"
  val dbName = "api"
  val postgresUsername = "postgres"
  val postgresPassword = "postgres"
  val source = new PGPoolingDataSource

  def configure = {
    try {
      source.setDataSourceName("Postgres");
      source.setServerName(postgresHost);
      source.setDatabaseName(dbName);
      source.setUser(postgresUsername);
      source.setPassword(postgresPassword);
      source.setMaxConnections(300);

      testConnection
    } catch {
      case e => logger.error(e.getMessage)
    }
  }

  def testConnection = {
      val tc = source.getConnection
      val meta = tc.getMetaData
      val cols = meta.getColumns(null, null, "postgres", null)
      cols.next
      logger.info("Postgres connection pool established")
      tc.close
  }

  def getConnection : Connection = {
    val c = source.getConnection
    logger.info("pg connection opened")
    c
  }

  def close(c: Connection) = {
    c.close
    logger.info("pg connection closed")
  }
}
{% endhighlight %}

How it's used by other classes:
{% highlight scala %}

val pgConnection = dbConnector.getConnection

// do sql stuff,
// val resultSet = pgConnection.createStatement.executeQuery("select * from blah")

dbConnector.close(pgConnection)
{% endhighlight %}

And how's it's implemented in my Scalatra app (runs at app startup)
In `ScalatraBootstrap.scala`

{% highlight scala %}
class ScalatraBootstrap extends LifeCycle {
  override def init(context: ServletContext) {
    dbConnector.configure //  start the connection pool

    context.mount(new GreetingServlet, "/greetings")
    context.mount(new WordServlet, "/words")
  }
}
{% endhighlight %}
