---
layout: post
title:  "curator cache and watch"
date:   2017-08-05 19:09:39
categories: tools
excerpt: using Apache Curator API to watch ZooKeeper zNodes
tags:
  - kafka
  - scala
---

The Apache Curator API is pretty slick.  It is written in a "fluent" style making it nice and readable.  Also the use of "anonymous functions" aka lamdas make it fun to work with.

Let's examine the `PathChildrenCache` class.  A `PathChildrenCache` is a construct that does local mirroring of a ZooKeeper path.  We can set up an "event handler" for the cache, which will be called when an event takes place on a watched zNode.  There's an ENUM which contains all possible events, and our event handler will match on the type of event.  Holy crap I'm having JavaScript flash backs here...

requirements:
{% highlight scala %}
// build.sbt
libraryDependencies ++= Seq(
  "org.apache.zookeeper" % "zookeeper" % "3.4.10",
  "org.apache.curator" % "curator-framework" % "2.12.0",
  "org.apache.curator" % "curator-recipes" % "2.12.0"
)

// imports
import org.apache.curator.framework.{CuratorFramework, CuratorFrameworkFactory}
import org.apache.curator.framework.recipes.cache.{PathChildrenCache, PathChildrenCacheEvent, PathChildrenCacheListener}
import org.apache.curator.retry.ExponentialBackoffRetry
{% endhighlight %}

The basic setup:
{% highlight scala %}

val zkConnectString = sys.env("ZOOKEEPER_CONNECTION_STRING")
val path = "/little"

val retryPolicy = new ExponentialBackoffRetry(1000, 3)
val client = CuratorFrameworkFactory.newClient(zkConnectString, retryPolicy)

/**
 * @param client    the client
 * @param path      path to watch
 * @param cacheData if true, node contents are cached in addition to the stat
 */
val cache = new PathChildrenCache(client, path, true)  
{% endhighlight %}


Now we add a "callback" in the form of a `PathChildrenCacheListener` (and a helper just to print stuff out for now).

To use the `PathChildrenCacheListener` interface we need to implement a `childEvent` method:
{% highlight scala %}
private def prettyPrintEvent(event: PathChildrenCacheEvent): (String, String) = {
  event.getData.getPath -> new String(event.getData.getData, "UTF-8")
}

cache.getListenable.addListener(new PathChildrenCacheListener {
  override def childEvent(client: CuratorFramework, event: PathChildrenCacheEvent): Unit = {
    event.getType match {
      case PathChildrenCacheEvent.Type.CHILD_ADDED => println(s"Child added: ${prettyPrintEvent(event)}")
      case PathChildrenCacheEvent.Type.CHILD_REMOVED => println(s"Child removed: ${prettyPrintEvent(event)}")
      case PathChildrenCacheEvent.Type.CHILD_UPDATED => println(s"Child updated: ${prettyPrintEvent(event)}")
      case _ => println(event.getType)
    }
  }
})
{% endhighlight %}

Now just add some basic driver code and watch the output to see the `PathChildrenCacheListener` in action!

{% highlight scala %}
client.start
cache.start

val nestedPath1 = path + "/dragon"
val nestedPath2 = path + "/louis"
val data1 = "first bit of data"
val data2 = "second bit"
val data3 = "third"
val data4 = "fourth"

List(path, nestedPath1, nestedPath2).foreach(path => {
  if (client.checkExists.creatingParentContainersIfNeeded.forPath(path) == null)
    try { client.create.creatingParentContainersIfNeeded.forPath(path) }
    catch { case e:NodeExistsException => println(e.getMessage)}
  Thread.sleep(500)
})

client.setData.forPath(nestedPath1, data1.getBytes)
Thread.sleep(500)
client.setData.forPath(nestedPath2, data2.getBytes)
Thread.sleep(500)
client.setData.forPath(nestedPath1, data3.getBytes)
Thread.sleep(500)
client.setData.forPath(nestedPath2, data4.getBytes)
Thread.sleep(500)


cache.close
client.close

// output.....
// CONNECTION_RECONNECTED
// Child added: (/little/dragon,192.168.1.12)
// Child added: (/little/louis,192.168.1.12)
// Child updated: (/little/dragon,first bit of data)
// Child updated: (/little/louis,second bit)
// Child updated: (/little/dragon,third)
// Child updated: (/little/louis,fourth)
//
{% endhighlight %}

Why all the `Thread.sleep`'s?  Good question.  These Curator methods all seem to run as background processes, meaning that synchronous execution cannot be guaranteed.  It is even more confusing to me as the `SyncBuilder` part of the library is ["always in the background"](https://curator.apache.org/apidocs/org/apache/curator/framework/CuratorFramework.html#sync--) which is the opposite of how other frameworks like Node.js implements `sync`.  More research will be needed. 
