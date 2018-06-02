---
layout: post
title:  "slick playground"
date:   2018-06-02 13:52:04
categories: databases
excerpt: "a recipe for loading Scala Slick in a REPL session for live experimentation"
tags:
  - scala
  - slick
  - postgres
---

[Slick](http://slick.lightbend.com/) provides a very "Scala" way to do SQL.

I love learning new tools in a REPL environment, so I thought I'd document my workflow here.

### Prereq
- download the [Ammonite-REPL](http://ammonite.io/)
- start a local Postgres container

{% highlight bash %}
docker run -d -p 5432:5432 \
  -e "POSTGRES_USER=postgres" \
  -e POSTGRES_PASSWORD=postgres \
  -e "POSTGRES_DB=postgres" \
  postgres:10.3
{% endhighlight %}

### Steps

Load up a new Ammonite session:
{% highlight bash %}
$ amm
# Loading...
# Welcome to the Ammonite Repl
# (Scala 2.12.3 Java 1.8.0_101)
{% endhighlight %}

*!!! note scala version is 2.12 in this example*

Run the following in the `amm` session to imports the needed Slick dependencies:

{% highlight scala %}
import $ivy.`com.typesafe.slick:slick_2.12:3.2.3`
import $ivy.`org.postgresql:postgresql:9.4.1212`

import java.sql.Timestamp
import slick.jdbc.JdbcBackend.Database
import slick.jdbc.PostgresProfile.Table
import slick.jdbc.PostgresProfile.api._
import slick.lifted.Tag

import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.Future

{% endhighlight %}

Ok now let's play!  First we need to establish a connection with our PG instance:

{% highlight scala %}
val pgUrl = "jdbc:postgresql://localhost:5432/postgres"
val pgUser = "postgres"
val pgPassword = "postgres"
val pgDriver = "org.postgresql.Driver"

val db = Database.forURL(
    url = pgUrl,
    user = pgUser,
    password = pgPassword,
    driver = pgDriver
)
{% endhighlight %}

Now we can run the examples seen on [http://slick.lightbend.com/doc/3.2.3/gettingstarted.html#schema](http://slick.lightbend.com/doc/3.2.3/gettingstarted.html#schema) in a live REPL session.
