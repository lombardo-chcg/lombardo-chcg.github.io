---
layout: post
title:  "custom redis action"
date:   2017-05-25 07:20:59
categories: databases
excerpt: "create a redis docker image that is preloaded with custom data"
tags:
  - docker
  - redis
---

Here's a quick walkthru on how to create a Redis docker image that spawns containers preloaded with custom data.

### Step 1: Prepare data for mass insertion into Redis
Prepare raw data for mass insertion into Redis using the [Redis Protocol](https://redis.io/topics/protocol).  

[See my previous post](/databases/2017/05/20/the-redis-protocol.html) about how to generate Redis protocol

To follow this example, save the Redis seed file to your local filesystem as `data/MY_DATA.txt`

### Step 2: Pipe data into Redis

Start Redis Docker container
{% highlight bash %}
docker run -d --name redis -p "6379:6379" redis
{% endhighlight %}

copy local data file to `/data` directory inside running container
{% highlight bash %}
docker cp data/MY_DATA.txt redis:/data
{% endhighlight %}

start a bash session inside the Redis container and run the [mass insertion command](https://redis.io/topics/mass-insert)

*note: by default the container places our session in the desired '/data' path*
*
{% highlight bash %}
docker exec -it redis bash

> cat MY_DATA.txt | redis-cli --pipe

# All data transferred. Waiting for the last reply...
# Last reply received from server.
# errors: 0, replies: 161019
{% endhighlight %}

Now our data has been loaded into Redis!  It will persist until this container is destroyed.  But let's take it a bit further.

### Step 3: Export database to local file system
Redis offers a quick and easy way to export this newly created database. [from the Redis docs:](https://redis.io/topics/persistence)
> By default Redis saves snapshots of the dataset on disk, in a binary file called dump.rdb.

To start, `exit` the bash session in the Redis container

then copy the special Redis snapshot file (`dump.rdb`) to local file system.

{% highlight bash %}
docker cp redis:/data/dump.rdb ./data
{% endhighlight %}

### Step 4: Create a custom Resis Docker image
with the Redis database preloaded.

in your `Dockerfile`:

{% highlight bash %}
FROM redis

ADD data/dump.rdb /data/dump.rdb
{% endhighlight %}

When containers spin up, they will automatically load the data in their `dump` file and be ready to go.

### Step 5: Check the work
* destroy previous container
* build new image
* run container based on new image

{% highlight bash %}
docker rm -f redis

docker build -t redis_test .

docker run -d --name redis_test -p "6379:6379" redis_test
{% endhighlight %}

Check your work.  Open a `redis-cli` session inside your container and query your data using standard Redis commands

{% highlight bash %}
docker exec -it redis_test redis-cli

# run a standard Redis command to access your data
127.0.0.1:6379> GET mykey
{% endhighlight %}

*SHIP IT!*
