---
layout: post
title:  "postgres schemas"
date:   2017-01-07 12:48:19
categories: databases
excerpt: "what the heck is a postgres schema?"
tags:
  - postgres
---

In my experience to date, I knew a database schema as the meta description of the data and relationships inside the database.  For example, in a SQL DB, the schema would describe the tables and the "has many", "has one", etc relationships.

Since I've started working with Postgres, there is a new use of the word schema. In Postgres, a schema is comparable to a directory in a file system.  A Postgres server can have many databases, each database can have many schemas.  Each schema can contain many tables, but also other objects such as functions and sequences.

Postgres DB admins can use schemas to organize a database and for many other things.  Each DB automatically contains a schema called public, but many more can be added.

This has an impact on writing SQL queries in Postgres in that you have to reference the schema and table to insert/access the data.  Here's an example using the `psql` cli in mac os x to create a schema called `people` with a table called `friends`:
{% highlight bash %}
create schema people;
create table people.friends(firstname CHAR(15), lastname CHAR(50));
insert into people.friends values( 'bobby', 'bottleservice' );
select * from people.friends;
{% endhighlight %}
