---
layout: post
title:  "the unix process tree"
date:   2017-07-19 07:06:47
categories: environment
excerpt: "the basics of processes in a Unix-based system"
tags:
  - mac
---

A concept that is taken for granted in everyday computing is that of a `process`.  At the base level, what is this concept?

> Processes carry out tasks within the operating system. A program is a set of machine code instructions and data stored in an executable image on disk and is, as such, a passive entity; a process can be thought of as a computer program in action.
[http://www.tldp.org/LDP/tlk/kernel/processes.html](http://www.tldp.org/LDP/tlk/kernel/processes.html)

So a comparison could be Docker: a Docker container is a Docker image in action, similar to how a Unix process is "a computer program in action".

> Every process in the system, except the initial process has a parent process

This means there is a tree structure to process management.  Each process has a parent, and can also have siblings.

At the top of the tree is the `initial process` or `init`.  This process is started by the kernel based on a `init` program located in the file system.

On my laptop running a Lubuntu distribution, the `init` file is located at `/sbin/init`

{% highlight bash %}
ls -l sbin | grep init
{% endhighlight %}

When started a boot time, this process is assigned a PID (process id) of 1.  It then spawns child processes to get the system up and running.

In my Linux box, `ps axjf` shows the standard `ps` process output, but also includes a visual representation of the tree relationships between processes.  PID 1 corresponds to the `/sbin/init` command.

To get the same view on a Mac, `brew install pstree` and then run the `pstree` command.

Things work a little differently inside a Docker container.  I will cover that down the road.
