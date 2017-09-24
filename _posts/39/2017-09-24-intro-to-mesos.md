---
layout: post
title:  "intro to mesos"
date:   2017-09-24 08:38:49
categories: environment
excerpt: "understanding apache mesos"
tags:
  - dcos
  - marathon
  - cloud
---

Apache Mesos is one of the most powerful tools available today for solving the problems of running a distributed system.  Before we look at Mesos specifically, let's understand the problem space.

First, what is a distributed system?  There are many ways to bake that cake, but one of them is to have a network of connected computers (nodes), consisting of a "scheduler" or leader node, which distributes tasks to worker nodes.

There are many functionalities that all distributed systems provide* :
* failure detection
* task distribution
* task starting, monitoring, cleanup

*\*source: [twitter university](https://www.youtube.com/watch?v=n5GT7OFSh58)*

The power of Mesos is that it provides all this basic distributed system plumbing, so that a developer does not have to re-implement these core functionalities for every project.  A developer is able to interact with an abstraction layer that Mesos provides in the form of an API.

How does this look?  Instead of a user having to write software that manages the low-level functionalities for an entire cluster of computers, in addition to the complexities of running their actual software, the developer instead interfaces with a Mesos master node, which is handling all the plumbing, and gets to focus all their efforts on their own project.

There is some special language in the Mesos world that we need to understand. From the Mesos [docs](https://people.eecs.berkeley.edu/~alig/papers/mesos.pdf):

> Mesos consists of a 'master' process that manages 'slave' daemons running on each cluster node, and 'frameworks' that run 'tasks' on these slaves.

Now that we have some background, this makes sense.  The developer interacts with the Mesos Master node thru a program called a "framework".

A "task" in the Mesos world is any piece of computing work.  Tasks can have a short lifecycle, such as running a computation on a dataset and returning a result.  Tasks can also be long-running, such as starting a Java Spring web service and letting it run for the lifespan of a project.

A "scheduler" is the program that interfaces with the Mesos master node, creates new tasks and tells Mesos where to run them.  We will dive more into this interaction in the next post.
