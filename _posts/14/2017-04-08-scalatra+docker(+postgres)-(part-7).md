---
layout: post
title:  "scalatra+docker(+postgres) (part 7)"
date:   2017-04-08 22:05:28
categories: web-dev
excerpt: "connecting our scala web app to a postgres db"
tags:
  - postgres
  - scala
  - docker
---

[Here's a github repo which will track this project](https://github.com/lombardo-chcg/scalatra-docker)

--

[Last time](/web-dev/2017/04/08/scalatra+docker-(part-6).html) we got our Postgres DB ready to serve up data.  Now let's go ahead and connect to it.

Since the goal of this series is to learn the fundamentals, I decided not to go with a 3rd party ORM tool that provides sugary syntax for connecting to a persistence layer.  I am more interested in getting my hands dirty and learning how things really work.  So, I decided to import only the basic Java SQL and Postgres tools and roll the rest myself.

The result is far from perfect...I basically hacked my way to an MVP solution.  But I had a lot of fun and learned a lot.  

One big takeaway is that working with the `ResultSet` class that gets returned from a SQL query can be very confusing.  The API was not clear to me and I had a hell of a time mappings its highly imperative and mutable  nature to the more functional nature I strive for in Scala code.

[Here's the MVP implementation](https://github.com/lombardo-chcg/scalatra-docker/blob/b3393add2d64f99d17bdcfb61c338659139f4484/src/main/scala/com/lombardo/app/services/RepositoryService.scala)

The idea of this RepositoryService is that a service can call it and pass in just the name of the resource (aka the sql table) and the RepositoryService will figure out the column names and pass back a list of maps that represent the table.  

Basically, turn this request:
{% highlight scala %}
greetingService.getOne(id)
{% endhighlight %}
into this SQL:
{% highlight sql %}
id | language |     content      |        create_date         
----+----------+------------------+----------------------------
 3 | French   | Bonjour le monde | 2017-04-08 15:27:30.168371
 {% endhighlight %}
into this Scala Map:
{% highlight scala %}
Map(id -> 3, language -> French, content -> Bonjour le monde, create_date -> 2017-04-09 02:32:57.760932)
{% endhighlight %}
then into a Scala case class for type safety
{% highlight scala %}
Greeting(3,French,Bonjour le monde,2017-04-09 02:32:57.760932)
{% endhighlight %}
and then into json for outward transmission:
{% highlight json %}
{
  "id": 3,
  "language": "French",
  "content": "Bonjour le monde",
  "create_date": "2017-04-09 02:32:57.760932"
}
{% endhighlight %}

[There's a lot of stuff in the PR](https://github.com/lombardo-chcg/scalatra-docker/commit/cb0665134a5742be0755b48667f632ceed5fbb86), from refactoring the Servlet to be named after the `Greeting` resource it represents to creating a `Service` layer and the above-mentioned `Repository` layer.  Further improvement ideas:

* database interactions need to return Option[Type] for null handling
* add the rest of the CRUD operations
* find a more Scala way of mapping the sql `ResultSet` into a Scala collection (look into the Stream class)
* add Postgres dependency as a injected variable
* clean up the way PG connections are established (execute in the `ScalatraBootstrap` class and inject into the `RepositoryService` class)

--

[work covered in this post](https://github.com/lombardo-chcg/scalatra-docker/commit/cb0665134a5742be0755b48667f632ceed5fbb86)
