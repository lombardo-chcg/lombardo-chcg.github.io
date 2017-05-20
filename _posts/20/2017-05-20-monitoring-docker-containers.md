---
layout: post
title:  "monitoring docker containers"
date:   2017-05-20 18:03:36
categories: tools
excerpt: "keeping an eye on runtime performance"
tags:
  - docker
  - environment
---

I am a serious Docker Fanboy at this point and I learned another cool trick today.

{% highlight bash %}
docker stats
{% endhighlight %}

This command gives all kinds of useful insight, and also streams in real time so you can monitor as operations are occurring.  When combined with logging, these stats can be a powerful debugging tool.

Once strange design decision is to include container ids and not container names in the standard output:

{% highlight bash %}
CONTAINER           CPU %               MEM USAGE / LIMIT       MEM %               NET I/O             BLOCK I/O           PIDS
11bff73591b9        0.19%               567.8 MiB / 1.952 GiB   28.40%              39.4 kB / 1.75 MB   24.6 kB / 0 B       23
{% endhighlight %}

My use case required the names of the containers to be present on the stats watcher, which is easily done with the standard Docker formatting option:

{% highlight bash %}
docker stats --format "table {% raw %}{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"{% endraw %}

NAME                  CPU %               MEM USAGE / LIMIT
scrabble-helper-api   0.18%               567.8 MiB / 1.952 GiB
redis                 0.18%               26.79 MiB / 1.952 GiB
postgres              0.00%               83.71 MiB / 1.952 GiB
{% endhighlight %}
