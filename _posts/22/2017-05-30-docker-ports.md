---
layout: post
title:  "docker ports"
date:   2017-05-30 22:00:13
categories: tools
excerpt: "quick way to get the exposed port from a running container"
tags:
  - docker
  - networking
---

Say you have an integration test environment where Docker ports are assigned randomly and cannot be assigned statically (due to the potential for port conflicts).  Is there a quick was to stash the exposed port in a env variable?

Start a sample container for the example:
{% highlight bash %}
docker run -P -d --name random_port_container redis

docker ps --format {% raw %}"{{.ID}}-{{.Names}}: {{.Ports}}"{% endraw %}
# 8736cdfdffa2-random_port_container: 0.0.0.0:32769->6379/tcp
{% endhighlight %}

So basically we want to stash the exposed port `32769` in a variable.  `docker port` to the rescue.  And since the internal application port is static, that makes our job even easier.

{% highlight bash %}
docker port random_port_container 6379/tcp
# 0.0.0.0:32769
{% endhighlight %}

`sed` for the win:

{% highlight bash %}
CONTAINER_PORT=$(docker port random_port_container 6379/tcp | sed "s|.*:||")

echo $CONTAINER_PORT
# 32769
{% endhighlight %}
