---
layout: post
title:  "zookeeper leader election"
date:   2017-08-12 11:39:31
categories: tools
excerpt: "implementing a zookeeper leader election recipe using scala & curator"
tags:
  - apache
  - kafka
  - distributed
  - scala
---

Leader Election is a super-cool concept that Apache ZooKeeper is known for.  What's the use case for leader election?

* Say you have a bunch of instances of an application running in an environment for maximum availability
* Also say there's a unique process that this application needs to run (such as a scheduled job)
* however, only 1 of this scheduled process should ever be running at a time
* therefore only a single instance of the app should run this process.  
* how do we know which instance of the app is going to run the job?  what happens if that instance tips over?

An easy solution to this is to elect one of the instances as the "Leader" using ZooKeeper.  Based on the concept of a ["heartbeat"](https://zookeeper.apache.org/doc/trunk/zookeeperProgrammers.html#ch_zkSessions), ZooKeeper will know when an app has tipped over and will simply elect a new leader.

We just need to include some basic code in our application to only run the special process when that instance is the "leader".

The Apache Curator library makes this dead simple using the `LeaderLatch` class.

This `LeaderLatch` class uses the concept of a ["CountDownLatch"](https://docs.oracle.com/javase/7/docs/api/java/util/concurrent/CountDownLatch.html) which is kinda like a gatekeeper.  The `leaderLatch.await` method process will block until the latch is lifted, aka when ZooKeeper informs the client that it is the new leader and the next line of code is processed.  Once that happens we know our instance is the new leader and it can proceed with running the special scheduled-job process.  

The key is that all instances point to the same zNode, in this case `/testing-leadership`.  That way ZooKeeper will be aware of all participants.  

`ClusterService.scala`:
{% highlight scala %}
import org.apache.curator.framework.CuratorFrameworkFactory
import org.apache.curator.framework.recipes.leader.LeaderLatch
import org.apache.curator.retry.ExponentialBackoffRetry

class ClusterService {
  val zkConnectString = sys.env("ZOOKEEPER_CONNECTION_STRING")
  val retryPolicy = new ExponentialBackoffRetry(1000, 3)
  val client = CuratorFrameworkFactory.newClient(zkConnectString, retryPolicy)

  def run() = {
    client.start

    val leaderLatch = new LeaderLatch(client, "/testing-leadership")
    leaderLatch.start

    leaderLatch.await

    if (leaderLatch.hasLeadership) // do some stuff

    leaderLatch.close
    client.close
  }
}
{% endhighlight %}

I made a fun `docker-compose.yml` file which shows this process in action.  In the code, I have removed the `leaderLatch.close` and `client.close` lines, to simulate an app tipping over instead of following a proper shutdown strategy.  In the logs you will see ZooKeeper handling these failures and electing a new leader.  

The compose has 6 sample "instances" running, each one waits to be elected leader using `leaderLatch.await`.  Once elected, it does some basic logging and then kills itself.  

Copy this and run locally if you wanna nerd out on ZooKeeper and Curator!  Make sure to run `docker-compose up` in the foreground to watch the logs...

{% highlight yml %}
version: "2"

services:
  zookeeper:
    container_name: zookeeper
    image: confluentinc/cp-zookeeper:3.2.1
    ports:
      - "2181:2181"
    hostname: zookeeper
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181

  zookeeper_client_1:
    container_name: zookeeper_client_1
    image: lombardo/zookeeper_leader_election_example:0.0.1
    hostname: zookeeper_client_1
    links:
      - "zookeeper"
    environment:
      ZOOKEEPER_CONNECTION_STRING: "zookeeper:2181"

  zookeeper_client_3:
    container_name: zookeeper_client_3
    image: lombardo/zookeeper_leader_election_example:0.0.1
    hostname: zookeeper_client_3
    links:
      - "zookeeper"
    environment:
      ZOOKEEPER_CONNECTION_STRING: "zookeeper:2181"

  zookeeper_client_4:
    container_name: zookeeper_client_4
    image: lombardo/zookeeper_leader_election_example:0.0.1
    hostname: zookeeper_client_4
    links:
      - "zookeeper"
    environment:
      ZOOKEEPER_CONNECTION_STRING: "zookeeper:2181"

  zookeeper_client_5:
    container_name: zookeeper_client_5
    image: lombardo/zookeeper_leader_election_example:0.0.1
    hostname: zookeeper_client_5
    links:
      - "zookeeper"
    environment:
      ZOOKEEPER_CONNECTION_STRING: "zookeeper:2181"

  zookeeper_client_6:
    container_name: zookeeper_client_6
    image: lombardo/zookeeper_leader_election_example:0.0.1
    hostname: zookeeper_client_6
    links:
      - "zookeeper"
    environment:
      ZOOKEEPER_CONNECTION_STRING: "zookeeper:2181"

{% endhighlight %}
