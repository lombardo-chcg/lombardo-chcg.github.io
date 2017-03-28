---
layout: post
title:  "postgres+docker(part 1)"
date:   2017-03-26 14:49:48
categories: databases
excerpt: "spinning up a dockerized postgres and adding some data"
tags:
  - sql
  - postgres
  - docker
---

I'm planning to add a persistence layer to my [ongoing series about Scala+Docker development](), so I thought I would take a few minutes and practice with a containerized Postgres.

Here's the plan:

* launch a Postgres container
* create a table and populate with data (US area codes)
* make some queries

Let's go!  First, start a new directory and add a `docker-compose.yml` file ( I prefer docker-compose files over crafting long `Docker run` commands)

Here's the content of `docker-compose.yml`.  It's a super-straightforward, standard Postgres setup but we area also adding an new database called 'geography'.

{% highlight yml %}
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
        - POSTGRES_DB=geography
{% endhighlight %}

We also need some demo data.  [Let's use this csv file containing US area code data](https://github.com/ravisorg/Area-Code-Geolocation-Database/blob/master/us-area-code-cities.csv)

First let's create a local dir called `data` which we will then mount in our Docker container.  

*Quick trick to download a file from the terminal:*

{% highlight bash %}
mkdir data

url=https://raw.githubusercontent.com/ravisorg/Area-Code-Geolocation-Database/master/us-area-code-cities.csv

curl $url >> data/us-area-code-cities.csv
{% endhighlight %}

Now lets mount that data directory in our Postgres container so we can access it from inside the container.  Just add `volumes` to the bottom of our `docker-compose.yml` and specify that we will mount our local `./data` directory in the container at the path `/data`:

{% highlight yml %}
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
        - POSTGRES_DB=geography
      volumes:
        - ./data:/data
{% endhighlight %}

Alright!  We're ready.  Now start the container in the background with `docker-compose up -d`.

Once it is running, let's enter a bash session in the container: `docker exec -it postgres bash`

Once inside, let's make sure our data is there:
`cat data/us-area-code-cities.csv`

Nice.  Now lets use the `psql` cli tool and have some fun!

{% highlight sql %}
-- enter a psql session as the user 'postgres'
psql -U postgres

-- let's list out our databases
\l

-- cool.  let's connect to our geography database
\connect geography

-- create our area_codes schema (see note below about schemas)
create schema area_codes;

-- lets create our table for US area codes
CREATE TABLE area_codes.usa
(
CODE char(3),
CITY varchar(256),
STATE varchar(256),
COUNTRY char(2),
LATITUDE varchar(256),
LONGITUDE varchar(256)
);

-- now we need to import our CSV file into this table.
-- luckily Postgres makes this super easy
COPY area_codes.usa FROM '/data/us-area-code-cities.csv' DELIMITER ',' CSV;

-- Done!  now lets execute some SQL queries
select count(*) from area_codes.usa;
-- > 2766

-- which city has the 773 area code?
select * from area_codes.usa where code='773';
-- > WEST CHICAGO?? I don't think so.  This data set has issues...

-- how many total area codes are there in the USA?
select count (distinct code) from area_codes.usa;
-- > 298
{% endhighlight %}

Outstanding.  This was a great into to Postgres and Docker.  I look forward to more posts including making the data persist (right now, it will be gone when the container comes down) and also connecting Postgres to our Scalatra app.

--

**NOTE ABOUT POSTGRES SCHEMAS**

The term can be confusing.  [read more about it here](http://localhost:4000/databases/2017/01/07/postgres-schemas.html)
