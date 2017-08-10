---
layout: post
title:  "dependency visualizations"
date:   2017-08-09 21:47:00
categories: tools
excerpt: "using an sbt plugin to view a dependency graph for a scala project"
tags:
  - scalatra
  - java
---

In a lot of ways, modern day software development can feel like the art of stitching together 3rd party libraries for the heavy lifting and generalized tasks with chunks of custom business logic to nail the details.  The abundance of open-source libraries is a big part of what makes web technology move so quickly.

However, managing a huge set of 3rd party dependencies can cause lots of problems in any project.

Today I was troubleshooting some of these 3rd party dependency issues in a Scala project and I found a neato open-source project by Johannes Rudolph called [sbt-dependency-graph](https://github.com/jrudolph/sbt-dependency-graph).  This sbt plugin provides multiple ways to create a visual representation of a project's dependencies.

Here's some sample output from using the `dependencyBrowseGraph` command in my [ZooKeeper Client Demo](https://github.com/lombardo-chcg/zookeeper-client-demo) project:

![sbt dependency graph screengrab]({{ full_base_url }}/media/full_size_sbt_graph.png)
[*see full size*]({{ full_base_url }}/media/full_size_sbt_graph.png)

There's also a terminal tree-style output and a `whatDependsOn` command to drill down

{% highlight bash %}
sbt
> whatDependsOn org.apache.curator curator-client 2.12.0
# [info] org.apache.curator:curator-client:2.12.0
# [info]   +-org.apache.curator:curator-framework:2.12.0
# [info]     +-sbt-starter:sbt-starter_2.12:0.0.1 [S]
{% endhighlight %}

Great tool!
