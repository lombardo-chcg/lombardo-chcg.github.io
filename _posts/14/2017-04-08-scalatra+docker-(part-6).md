---
layout: post
title:  "scalatra+docker (part 6)"
date:   2017-04-08 09:57:45
categories: web-dev
excerpt: "preparing a postgres database for our api"
tags:
  - docker
  - postgres
---

[Here's a github repo which will track this project](https://github.com/lombardo-chcg/scalatra-docker)

--

Now that we've figured out how to containerize our Scalatra app, let's get back to developing!  

The next step will be preparing a database layer for the API to mirror a real world implementation.  For this example I've chosen to use Postgres.  SQL and therefore Postgres is not the "hottest" DB technology now but I still love it.  It reminds me of functional programming in the way that you can compose simple, declarative statements together to do incredibly complex tasks.  I'll say it.  SQL is cool.

In this section, we'll add a Postgres container to our app's ecosystem and migrate the "greetings" data model off our app and into the database.  Let's do it.

First, we need a `docker-compose` file that will handling the spinning up of our Postgres container.  [Follow along with this previous post to get the details of working with Docker and Postgres](/databases/2017/03/26/postgres+docker(part-1).html).

Here is our `docker-compose.yml` for this project:
{% highlight bash %}
version: '2.0'

services:
    postgres:
      image: postgres
      container_name: postgres
      ports:
        - "5431:5432"
      environment:
        - POSTGRES_USER=postgres
        - POSTGRES_PASSWORD=postgres
        - POSTGRES_DB=greeting
{% endhighlight %}

This will start our container.  But, we also need a table and some data so we can run queries against it from our application.  As seen in the previous tutorial, we can access files from within the `psql` cli.  Let's take advantage of that to run some `sql` commands against our database.

We'll make 2 SQL files: one to create a table, and one to seed it with data.

{% highlight bash %}
mkdir db
touch db/create_greetings_table.sql
touch db/seed_greetings_table.sql
{% endhighlight %}

In `create_greetings_table.sql` we will port over our Scala case class `Greeting` and add a ID and Timestamp field for good practice.

{% highlight sql %}
CREATE TABLE greetings (
  id serial PRIMARY KEY,
  language varchar(256) NOT NULL,
  content varchar(256) NOT NULL,
  create_date timestamp NOT NULL default now()
);
{% endhighlight %}

And in `seed_greetings_table.sql` we will plunk down our 4 greetings:

{% highlight sql %}
insert into greetings (language, content) values
  ('English', 'Hello World'),
  ('Spanish', 'Hola Mundo'),
  ('French', 'Bonjour le monde'),
  ('Italian', 'Ciao mondo')
;
{% endhighlight %}

Sweet.  Now we just need to bring it all together by making sure every time when our container starts, we have the "migration" scripts run.  Sounds like the perfect job for a bash script.

{% highlight bash %}
touch scripts/launch-postgres.sh
chmod a+x scripts/launch-postgres.sh
{% endhighlight %}

Our script will do the following actions:

* launch Postgres container
* copy over our two sql files
* execute the sql commands in those files using the `psql` cli

Here's the code:

{% highlight bash %}
#!/bin/bash

db_container="postgres"

docker-compose down
docker-compose up -d

docker cp db/create_greetings_table.sql $db_container:/docker-entrypoint-initdb.d/create_greetings_table.sql
docker cp db/seed_greetings_table.sql $db_container:/docker-entrypoint-initdb.d/seed_greetings_table.sql

docker exec -d \
  $db_container psql \
  --username=postgres \
  -f ./docker-entrypoint-initdb.d/create_greetings_table.sql

docker exec -d \
  $db_container psql \
  --username=postgres \
  -f ./docker-entrypoint-initdb.d/seed_greetings_table.sql
{% endhighlight %}

NOTE: What you see abovde is actually not the most efficient way to accomplish this task.  Any files in the container's `docker-entrypoint-initdb.d` directory will actually be auto-run by Docker when a Postgres container is spun up.  That would require a slightly different implementation, where we create a `dockerfile` and layer our scripts on top before launching a container.  I'll stick with this way for now, but keep that in mind.


Now we're ready to test.

{% highlight bash %}
./scripts/launch-postgres.sh

docker exec -it postgres bash

# now in a shell inside the container
psql -U postgres
{% endhighlight %}
{% highlight sql %}
\connect greeting
select * from greetings;

id | language |     content      |        create_date         
----+----------+------------------+----------------------------
 1 | English  | Hello World      | 2017-04-08 15:27:30.168371
 2 | Spanish  | Hola Mundo       | 2017-04-08 15:27:30.168371
 3 | French   | Bonjour le monde | 2017-04-08 15:27:30.168371
 4 | Italian  | Ciao mondo       | 2017-04-08 15:27:30.168371
(4 rows)
{% endhighlight %}

SUCCESS!  Our database now has data and is ready to be interacted with by our Scalatra app.  Next time, we will connect our Scala app to Postgres and start doing CRUD operations.

[Here's the code from this section](https://github.com/lombardo-chcg/scalatra-docker/commit/194d25192acd3c94ae55d725aaa99bc3efbd9914)
