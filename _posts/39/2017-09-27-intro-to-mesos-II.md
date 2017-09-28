---
layout: post
title:  "intro to mesos II"
date:   2017-09-27 21:23:29
categories: environment
excerpt: "investigating the Apache Mesos scheduler API"
tags:
  - dcos
  - marathon
  - cloud
---

[This video](https://www.youtube.com/watch?v=n5GT7OFSh58) featuring Benjamin Hindman, formerly of Twitter, now of Mesosphere, is a few years old but still a great watch for understanding Mesos.  What follows is basically my notes from watching this video.

--

A Scheduler is a piece of custom software written by a developer which interacts with a Mesos master node.  Recall that a Mesos Framework consists of a Scheduler and its Tasks.

The interaction between a Scheduler and the Mesos Master is not a request/response cycle of HTTP, but more of an Actor model, with unidirectional message passing.  

Here's a quick overview of an Scheduler/Master interaction:

1. Scheduler - I want to `Register`
2. Mesos - You have been `Registered`
3. Scheduler - I want to `Request` these specific resources (requests are optional)
4. Mesos - Here is an `offer` of some available resources
5. Scheduler - I don't need those - I `decline` your offer
6. Mesos - Here is an `offer` of some more available resources
5. Scheduler - Nice.  I want to `Launch` a task using these specific resources
6. Mesos - here is an `Update` on your task status after launch


The messages generally fall into 3 categories:

### 1. Lifecycle Management Messages

#### Scheduler ===> Mesos Master
* `Register` `Unregister` `Reregister` (failover)


#### Mesos Master ===> Scheduler
* `Registered` `Reregistered`

--

### 2. Resource Allocation Messages

#### Scheduler ===> Mesos Master
* `Request` `Decline` `Revive`

#### Mesos Master ===> Scheduler
* `Offer` `Rescind`

--

# 3. Task Management Messages

#### Scheduler ===> Mesos Master
* `Launch` `Kill` `Acknowledge`(status) `Reconcile`(status)

#### Mesos Master ===> Scheduler
* `Update`

--

#### Launching a task

The scheduler creates a `TaskInfo` struct and sends a `Launch` message to the Mesos Master
* `TaskInfo` includes SlaveID and the resources, and a Launch Command or an optional `Executor`  

The Master sends the task to the Mesos slave which has the resources
1. Launch Command - literally run a shell command to launch the task
2. `Executor` - Mesos slave hands the task to an `Executor` which is running on that slave, which launches the task

When a task is launched it is put into a container inside the Mesos slave (the executor or the task are inside the container)
