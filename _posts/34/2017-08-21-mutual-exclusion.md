---
layout: post
title:  "mutual exclusion"
date:   2017-08-21 20:21:30
categories: tools
excerpt: "using the mutex pattern to create locks using zookeeper and curator"
tags:
  - zookeeper
  - curator
  - apache
  - kafka
  - scala
---

One of the most fundamental problems in distributed systems is the danger of race conditions.  For example, multiple instances of the same application updating the same database record simultaneously.  Who wins?

There are [multiple ways](https://en.wikipedia.org/wiki/Mutual_exclusion#Software_solutions) to solve this problem.  Today I learned about how it works with ZooKeeper via the Curator client library and "locks".

[As discussed previously](https://lombardo-chcg.github.io/tools/2017/08/03/zookeeper-client-api.html), ZooKeeper implements a unix directory-like data structure, with each "path" known as a `zNode`.  Here's a quick recipe for "locking" a `zNode` so that no other processes may access it until the lock is released.  

Keep in mind that we can store the data itself in the ZooKeeper `zNode`, or we can use the `zNode` as a pointer to another resource in our system.  For example, creating a path that reflects the UUID of a database record.

Here's a quick example in Scala:

{% highlight scala %}
import org.apache.curator.framework.CuratorFrameworkFactory
import org.apache.curator.framework.recipes.locks.InterProcessMutex
import org.apache.curator.retry.ExponentialBackoffRetry

import scala.util.{Failure, Success, Try}

class LockService {
  val zkConnectString = sys.env("ZOOKEEPER_CONNECTION_STRING")
  val retryPolicy = new ExponentialBackoffRetry(1000, 3)
  val client = CuratorFrameworkFactory.newClient(zkConnectString, retryPolicy)
  val lockedPath = "/myResource"
  val dummyData = "starting data"

  client.start

  Try (client.create.creatingParentContainersIfNeeded.forPath(lockedPath, dummyData.getBytes)) match {
    case Success(_) => println(s"zNode $lockedPath created")
    case Failure(e) => println(e.getMessage)  // node already exists
  }

  val lock = new InterProcessMutex(client, lockedPath)

  lock.acquire

  client.setData.forPath(lockedPath, "bad data".getBytes)

  lock.release

  client.close
}
{% endhighlight %}

Any other processes attempting to aquire a lock on the `lockedPath` would be blocked until this lock is released.

Curator provides 2 methods for acquiring a lock:
* `public void acquire()` blocks until any existing lock is lifted.
* `public boolean acquire(long time, TimeUnit unit)` will attempt to gain a lock until the param-provided interval elapses.  This method is nice because it returns a boolean which is convenient for other services consuming this api.

There's a whole lot more functionality available in the Curator library around locks and the mutual exclusion pattern, but this is a simple introduction.
