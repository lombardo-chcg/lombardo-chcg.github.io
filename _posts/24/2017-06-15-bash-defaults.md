---
layout: post
title:  "bash defaults"
date:   2017-06-15 21:05:13
categories: tools
excerpt: "get or else on bash variables"
tags:
  - bash
---

Here's a quick way to provide a default value to a bash script in case one is not passed in as an argument:

build-docker-image.sh
{% highlight bash %}
#!/bin/bash

tag=${1:-latest}

docker build -t my_docker_image:$tag .
{% endhighlight %}

{% highlight bash %}
// usage

./scripts/build-docker-image.sh 1.3.0
# => my_docker_image:1.3.0

./scripts/build-docker-image.sh
# => my_docker_image:latest
{% endhighlight %}
