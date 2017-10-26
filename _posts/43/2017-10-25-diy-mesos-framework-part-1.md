---
layout: post
title:  "D.I.Y. mesos framework part 1"
date:   2017-10-25 20:25:17
categories: environment
excerpt: "launching a custom Apache Mesos framework in a local development environment"
tags:
  - apache
  - mesos
  - docker
  - cloud
---

[I've covered](/environment/2017/09/24/intro-to-mesos.html) Apache Mesos concepts in the past.  Now let's see it in action!

### Setup

I'm using a Mac so I will provide setup steps for running a local Mesos slave and master.

{% highlight bash %}
which mesos
# if none,
brew install mesos
{% endhighlight %}

Docker for Mac should also be installed and running.

Get your system's IP: `Apple` -> `System Preferences` -> `Network`.  The IP address will show up in the upper right.  Jot it down.  

Now open **4** terminal windows and let's begin.

### Launch Mesos Master and Agent

Terminal 1: Launch a Mesos Master node:
{% highlight bash %}
/usr/local/sbin/mesos-master --registry=in_memory ip=your_ip_address
{% endhighlight %}

Terminal 2: Launch a Mesos agent node:
{% highlight bash %}
# don't forget to put port 5050 after the ip address!
sudo /usr/local/sbin/mesos-slave --master=your_ip_address:5050 --work_dir=$(pwd)
{% endhighlight %}

### Register a custom Mesos Framework

Here is where the fun begins.  We will be using the Mesos HTTP Interface to create our Framework and manage tasks.

To create the Framework, we must use `curl` or another tool that will keep the connection open.  Why?  The HTTP response to our framework-creation request is "chunked" from the Mesos Master, which results in a connection being left open for the remainder of the framework's lifespan.  Offers, task updates, and other communications with the Master node come across this connection for parsing by the framework.  The effect is a "streaming" subscription to Mesos events.

NOTE:  the "user" in this command must be the same as the output of a `whoami` command in the terminal.  This becomes important later for launching tasks.

Terminal 3:

{% highlight bash %}
curl -v -X POST \
  http://localhost:5050/api/v1/scheduler \
  -H 'content-type: application/json' \
  -d '{
   "type" : "SUBSCRIBE",
    "subscribe"  : {
      "framework_info"  : {
        "user" :  "lombardo",
        "name" :  "HelloWorld Framework",
        "roles": ["hello_world_role"],
        "capabilities" : [{"type": "MULTI_ROLE"}]
      }
    }
  }'
{% endhighlight %}

We should see a "Subscribed" response from Mesos.  Note the following fields in the response:

{% highlight bash %}
Mesos-Stream-Id   - in the header - mine is 274bcc35-78db-42ac-8a10-b02944c5a6eb
framework_id   - 089a7212-4aba-4aac-8425-7337161ece30-0000
{% endhighlight %}

Immediately following the "Subscribed" event, we should see a "Offer".  This is Mesos letting us know about resources available on the agent node which we can use to launch our tasks.  Note the following fields in the offer:

{% highlight bash %}
agent_id      mine is 089a7212-4aba-4aac-8425-7337161ece30-S0
id            mine is 089a7212-4aba-4aac-8425-7337161ece30-O0
{% endhighlight %}

NOTE - the "id" of the offer is nested in the response at `id.value`

Now if we visit `http://localhost:5050` and click on "Frameworks" we will see our framework listed.  Nice!  We have just registered a custom framework with Mesos.

Next time we will launch some tasks.
