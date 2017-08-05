---
layout: post
title:  "zookeeper client api refactoring"
date:   2017-08-05 13:11:05
categories: tools
excerpt: "using the Apache Curator library and Scala Traits to refine zookeeper interactions"
tags:
  - scala
  - object
  - oriented
  - apache
  - kafka
  - zookeeper
---

[Yesterday](/tools/2017/08/03/zookeeper-client-api.html) I did an exploration of the Apache ZooKeeeper client library.

It turns out that Netflix created a wrapper around this client library to make it more fluent.  The project is called Curator and it is now an [Apache Project](http://curator.apache.org/index.html)

I thought it may be fun to refactor yesterday's challenge using Curator.  In the process, I learned something really cool about Scala traits.

As you recall from yesterday, we defined a `ZooKeeperHelperInterface` Trait which defined our interactions with the ZooKeeper server.

{% highlight scala %}
trait ZooKeeperHelperInterface {
  def nodeExists(path: String): Boolean
  def createNode(path: String, data: String): String
  def getData(path: String) : String
  def setData(path: String, data: String): Stat
  def getChildren(path: String): List[String]
}
{% endhighlight %}
It was a cinch to create a new class that extends that Trait and uses the fluent Curator library instead.  Here it is:

{% highlight scala %}
import org.apache.curator.framework.CuratorFramework
import org.apache.zookeeper.data.Stat
import scala.collection.JavaConverters._

class CuratorImpl(client: CuratorFramework) extends ZooKeeperHelperInterface {
  override def nodeExists(path: String): Boolean = {
    if (client.checkExists.forPath(path) == null ) false else true
  }

  override def createNode(path: String, data: String): String = {
    client.create.forPath(path, data.getBytes)
  }

  override def getData(path: String): String = {
    val returnedBytes = client.getData.forPath(path)
    new String(returnedBytes, "UTF-8")
  }

  override def setData(path: String, data: String): Stat = {
    client.setData.forPath(path, data.getBytes)
  }

  override def getChildren(path: String): List[String] = {
    client.getChildren.forPath(path).asScala.toList
  }
}
{% endhighlight %}

But now here's the really cool part.  I was able to turn my basic "runner" code that does the ZooKeeper interactions into a method, and then just pass in a `client` param that extends the `ZooKeeperHelperInterface`.  Check this out:

{% highlight scala %}
def runZkInteractions(client: ZooKeeperHelperInterface) = {
  val path = "/little"
  val nestedPath = path + "/dragon"
  val data1 = "i was looking at the trees"
  val data2 = "they were looking back at me"
  val data3 = "thoughts that occurred to me"
  val data4 = "not of the usual kind..."

  if (client.nodeExists(path)) client.setData(path, data1)
  else client.createNode(path, data1)

  println(client.getData(path))
  client.setData(path, data2)
  println(client.getData(path))

  if (client.nodeExists(nestedPath)) client.setData(nestedPath, data3)
  else client.createNode(nestedPath, data3)

  println(client.getData(nestedPath))
  client.setData(nestedPath, data4)
  println(client.getData(nestedPath))
  println(client.getChildren(path))
}
{% endhighlight %}

Which enable this:
{% highlight scala %}
runZkInteractions(basicInstanceApi)

runZkInteractions(curatorInstanceApi)
{% endhighlight %}

The `runZkInteractions` method doesn't care which instance gets passed in, only that it extend the `ZooKeeperHelperInterface`.

This 'plugin' style of inerface coding is common in Object-Oriented Design and it is really cool to see it in action.

Also, at these "hello world" level of ZooKeeper interactions, the Curator library doesn't really shine.  Its on the more advanced interactions where it really comes into its own.  I will show more of that soon.

[**Repo is here**](https://github.com/lombardo-chcg/zookeeper-client-demo)
