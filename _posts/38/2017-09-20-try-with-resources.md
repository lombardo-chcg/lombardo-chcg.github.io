---
layout: post
title:  "try with resources"
date:   2017-09-20 21:25:47
categories: languages
excerpt: "avoiding the finally block with java resources via a Apache Curator example"
tags:
  - java
  - jvm
  - curator
  - zookeeper
  - apache
---

Today I learned about the `try-with-resources Statement` that was included with Java 7.  To quote [the docs](https://docs.oracle.com/javase/tutorial/essential/exceptions/tryResourceClose.html):

* "A resource is an object that must be closed after the program is finished with it."
* "The try-with-resources statement ensures that each resource is closed at the end of the statement"
* "Any object that implements java.lang.AutoCloseable...can be used as a resource"

The basic gist here is that, when using a class that implements `AutoCloseable` / `Closeable`, we no longer have to include a `finally` block that closes the resource.

Here's an example using the Apache CuratorFramework:

{% highlight java %}
package com.lombardo.demo;

import org.apache.curator.framework.CuratorFramework;
import org.apache.curator.framework.CuratorFrameworkFactory;
import org.apache.curator.retry.ExponentialBackoffRetry;

public class CuratorService {
    private String zkConnectString = "localhost:2181";
    private ExponentialBackoffRetry retryPolicy = new ExponentialBackoffRetry(1000, 3);

    public String createNode(String path, String data) throws Exception {
        // passing in a 'Closable' CuratorFramework instance to the try statement
        try(CuratorFramework client = CuratorFrameworkFactory.newClient(zkConnectString, retryPolicy)) {
            client.start();
            return client.create().creatingParentContainersIfNeeded().forPath(path);
        }
        // .close() was called automatically
    }
}
{% endhighlight %}

as opposed to the `finally` block method:

{% highlight java %}
public String createNodeOldSchool(String path, String data) throws Exception {
    CuratorFramework client = CuratorFrameworkFactory.newClient(zkConnectString, retryPolicy);
    try {
        client.start();
        return client.create().creatingParentContainersIfNeeded().forPath(path);
    } finally {
        client.close();
    }
}
{% endhighlight %}
