---
layout: post
title:  "zookeeper client api"
date:   2017-08-03 23:32:12
categories: tools
excerpt: "exploring the Apache ZooKeeper api using scala"
tags:
  - apache
  - kafka
---

 > Because coordinating distributed systems is a Zoo
 > [https://cwiki.apache.org/confluence/display/ZOOKEEPER/Index](https://cwiki.apache.org/confluence/display/ZOOKEEPER/Index)

Since I am learning more about [Kafka](/search?term=kafka), I thought it would be beneficial to explore Apache Zookeeper, which is a required piece of infrastructure for a Kafka cluster.

So far on my Kafka learning spree, I have focused more on wiring up the software components, and not so much on the distributed nature of Kafka and the complexity that comes along with that.  That complexity is exactly what ZooKeeper handles.

So how does ZooKeeper fit in?  My understanding so far is: it acts as a single-source-of-truth orchestrator for distributed systems.  Applications running in a distributed manner can use ZooKeeper to store configuration information,  "watch" for event notifications, and for synchronization (i.e. avoiding race conditions).  ZooKeeper can also act as a "DNS" or naming service for the nodes of a distributed service.  ZooKeeper serves data out of memory, so it is extremely fast, and it itself can even be run in a distributed manner with massive replication, ensuring that if the "leader" falls over, other nodes are present to pick up the slack.

Ok, that's a ton of info.  And at this time I'm more interested in learning how it works from a client perspective.

So, it turns out Zookeeper is a type of key-value store mixed with a tree-like data structure.  The "keys" resemble file paths and have the same nested structure (i.e. parent / child) and the values are stored as Arrays of Bytes.

in the Language of Zookeeper, a key is known as a `zNode`.

{% highlight bash %}
/little/dragon          
{% endhighlight %}

There are 2 `zNodes` here: `/little` and `/dragon`.  `/dragon` is a child of `/little`.  This is just like a unix system directory structure.

ZooKeeper maintains "stats" for each `zNode`, which is known as a [`Stat` structure](https://zookeeper.apache.org/doc/r3.1.2/zookeeperProgrammers.html#sc_zkStatStructure).

That's some nice basic info.  Let's explore the client library for connecting to ZooKeeper.

First, start my [Docker For Mac Kafka Stack](https://github.com/lombardo-chcg/kafka-local-stack) so that ZK is running on localhost:2181.  You can also use my [sbt starter pack](https://github.com/lombardo-chcg/sbt-project-starter) for the application code.

add to `build.sbt`:
{% highlight scala %}
libraryDependencies += "org.apache.zookeeper" % "zookeeper" % "3.4.10"
{% endhighlight %}

The second step will be to create a [`ZooKeeper`](https://zookeeper.apache.org/doc/r3.4.10/api/org/apache/zookeeper/ZooKeeper.html) instance in our Scala app.  This process opens up a ZooKeeper session and allows us to communicate with the server.


The constructor for a `ZooKeeper` is
{% highlight java %}
ZooKeeper(String connectString, int sessionTimeout, Watcher watcher)
{% endhighlight %}

The [`Watcher`](https://zookeeper.apache.org/doc/r3.4.10/api/org/apache/zookeeper/Watcher.html) is reminicent of a callback function in JavaScript.  I may have to dive into that further down the road.

*this is some extreme boilerplate code that I have ported over from [this Java example](https://www.tutorialspoint.com/zookeeper/zookeeper_api.htm)*
{% highlight scala %}
import java.util.concurrent.CountDownLatch

import org.apache.zookeeper.Watcher.Event.KeeperState
import org.apache.zookeeper._

class ZookeeperConnectionApi {
  val connectedSignal = new CountDownLatch(1)

  def getConnection() : ZooKeeper =  {
    val zkConn = new ZooKeeper("localhost:2181", 5000, new Watcher {

      def process(we: WatchedEvent) {

        if (we.getState == KeeperState.SyncConnected) {
          connectedSignal.countDown
        }
      }
    })

    connectedSignal.await
    zkConn
  }

  def close(zkConn: ZooKeeper) = zkConn.close
}
{% endhighlight %}

Now that we can connect to the server, let's explore the client API by writing some helper methods that wrap the Apache library.  We'll check out some basic CRUD stuff, and also see about the children.  Here's the interface:

{% highlight scala %}
trait ZooKeeperHelperInterface {
  def nodeExists(path: String): Boolean
  def createNode(path: String, data: String): String
  def getData(path: String) : String
  def setData(path: String, data: String): Stat
  def getChildren(path: String): List[String]
}
{% endhighlight %}

Now let's do an implementation.  For this simple example, this class will take an instance of the `ZooKeeper` class in its constructor (`zkConn`), which is returned by using our `ZookeeperConnectionApi` class above.

{% highlight scala %}
import org.apache.zookeeper._
import org.apache.zookeeper.data.Stat

import scala.collection.JavaConverters._

class ZooKeeperHelper(zkConn: ZooKeeper) extends ZooKeeperHelperInterface {
  override def nodeExists(path: String): Boolean = {
    if (zkConn.exists(path, true) == null ) false else true
  }

  override def createNode(path: String, data: String): String = {
    zkConn.create(path, data.getBytes, ZooDefs.Ids.OPEN_ACL_UNSAFE, CreateMode.PERSISTENT)
  }

  override def getData(path: String): String = {
    val returnedBytes = zkConn.getData(path, false, null)
    new String(returnedBytes, "UTF-8")
  }

  override def setData(path: String, data: String): Stat = {
    val node = zkConn.exists(path, true)
    zkConn.setData(path, data.getBytes, node.getVersion)
  }

  override def getChildren(path: String): List[String] = {
    zkConn.getChildren(path, false).asScala.toList
  }
}
{% endhighlight %}


Very fluent API.  As we can see we are serializing the data into Byte Arrays to communicate with the ZooKeeper server.

Here's a basic little runner for our helper methods just to see how it all works.
{% highlight scala %}
object Main {
  def main(args: Array[String]) {
    println("Hello from sbt starter pack!")

    val zkManagerApi = new ZooKeeperConnectionApi
    val zkConn = zkManagerApi.getConnection
    val zkInstanceApi = new ZooKeeperHelper(zkConn)

    val path = "/little"
    val nestedPath = path + "/dragon"
    val data1 = "i was looking at the trees"
    val data2 = "they were looking back at me"
    val data3 = "thoughts that occurred to me"
    val data4 = "not of the usual kind..."

    if (zkInstanceApi.nodeExists(path)) zkInstanceApi.setData(path, data1)
    else zkInstanceApi.createNode(path, data1)

    println(zkInstanceApi.getData(path))
    zkInstanceApi.setData(path, data2)
    println(zkInstanceApi.getData(path))

    if (zkInstanceApi.nodeExists(nestedPath)) zkInstanceApi.setData(nestedPath, data3)
    else zkInstanceApi.createNode(nestedPath, data3)

    println(zkInstanceApi.getData(nestedPath))
    zkInstanceApi.setData(nestedPath, data4)
    println(zkInstanceApi.getData(nestedPath))
    println(zkInstanceApi.getChildren(path))

    zkManagerApi.close(zkConn)
  }
}
{% endhighlight %}

output...
{% highlight bash %}
i was looking at the trees
they were looking back at me
thoughts that occurred to me
not of the usual kind...
List(dragon)

Process finished with exit code 0
{% endhighlight %}
