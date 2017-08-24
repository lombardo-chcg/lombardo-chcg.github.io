---
layout: post
title:  "the zookeeper connection"
date:   2017-08-24 03:42:03
categories: tools
excerpt: "using the zkCli tool to interact with apache zookeeper"
tags:
  - apache
  - kafka
  - bash
---

As I am beginning to work more with ZooKeeper, I find it helpful to enter a terminal session inside ZooKeeper to poke around and explore.

It's very easy on a Mac:

{% highlight bash %}
brew install zookeeper

# start a local zk instance just for fun
docker run -d -p "2181:2181" -e "ZOOKEEPER_CLIENT_PORT=2181" confluentinc/cp-zookeeper:3.2.1

# connect
zkCli -server localhost:2181
{% endhighlight %}

Once you see a watcher has been established, press enter to begin a terminal session.

`help` provides a list of commands.  The commands I found useful are

{% highlight bash %}
create /sample-node "some data"
ls /
get /sample-node   # data + metadata
stat /sample-node  # metadata only
rmr /parent-to-delete  # same as unix rm -rf
{% endhighlight %}

The utility is also available as a shell script that can be placed on the path for quick access: [https://github.com/apache/zookeeper/blob/master/bin/zkCli.sh](https://github.com/apache/zookeeper/blob/master/bin/zkCli.sh)
