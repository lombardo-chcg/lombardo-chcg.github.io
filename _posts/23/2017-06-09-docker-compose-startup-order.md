---
layout: post
title:  "docker-compose startup order"
date:   2017-06-09 18:46:39
categories: tools
excerpt: "managing dependencies using Docker compose"
tags:
  - docker
  - application-design
  - scala
  - scalatra
---

As part of my [Scrabble-Docker-Scala](/search?term=scalatra) project, one issue I was having when preparing for deployment was the Scalatra API's dependency on Postgres.  

As the API was firing up, it attempted to make a connection to PG to establish a connection pool.  However, PG was taking too long to start, and the application was choking when the dependency wasn't available.

Docker Compose offers a `depends_on` directive, but this doesn't solve the problem.  It purely controlls the start order.  It does not wait for an applicaiton to be fully available.

So I started reading about best practices to solve this problem.  There are container automation libraries available, and a nifty little bash library called [Wait For It](https://github.com/vishnubob/wait-for-it) that can be used as a `command` in a Docker Compose file.

But something I read on the [Docker Compose docs](https://docs.docker.com/compose/startup-order/) really caught my attention:

> The problem of waiting for a database (for example) to be ready is really just a subset of a much larger problem of distributed systems. In production, your database could become unavailable or move hosts at any time. Your application needs to be resilient to these types of failures.

Challenge Accepted!

One strategy I've seen used in production code is a back-off/retry policy.  Basically this is a piece of code that tries to perform and action, and if the action fails, it keeps retrying.  The back-off portion means it can retry and slower and slower intervals, such as exponents or even fibanacci numbers (i.e. wait 1 sec before a retry, then 2, then 3, then 5, then 8, etc)

I decided to implement that in my Scala app as a wrapper method.  It takes a number of retries and a operation that may fail as arguments, and returns any Type.

If the call fails, and the number of retries has not been exceeded, it simply calls itself with the counter decremented by one.

This implementation is a `Thread.sleep` which is basic and blocks the app from starting until it is resolved.  A more advanced implementation would be an async style with a callback.  But I'll save that for another day.

{% highlight scala %}
private def retry[T](times: Int)(func: => T): T = {
  try {
    func
  } catch {
    case e : Throwable =>
      if (times > 1) {
        logger.error(s"""Could not connect to Postgres.  Will attempt ${times - 1} more times""")
        Thread.sleep(5000)
        retry(times - 1 )(func)
      }
      else {
        logger.error(e.getMessage)
        throw e
      }
  }
}
{% endhighlight %}

Usage with a method called `establishPostgresConnection`:

{% highlight scala %}
retry(10){ establishPostgresConnection }
{% endhighlight %}
