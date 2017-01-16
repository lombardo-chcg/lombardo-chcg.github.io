---
layout: post
title:  "local development with docker"
date:   2017-01-15 17:45:32
categories: environment
excerpt: "mount a local directory in a docker container"
tags:
  - docker
---

The Problem: My local development environment and my deployment environment (Docker containers) don't match and it is leading to unpredictable bugs.

The Unknown: How do I develop my applications inside a Docker container but still maintain a short feedback loop?  (i.e. being able to see saved code changes instantly in the container, without having to kill and rebuild the container)

The Solution: Create a base image that mirrors the deployed image.  For example, if you have a JavaScript one-page application that is served up in an Nginx container, create a base image with the same Nginx config.  If the config file has a `root` location in `var/web/assets` where the `index.html` file usually lives, keep that configuration in place.  But leave out the part in the Docker file where you `ADD` your code to the `var/web/assets` path.

Instead, when you run this development container, simply mount your local working directory in the container as a volume.  Docker provides this functionality out of the box.

Assuming your `index.html` file is in a local directory called `/public`:

{% highlight bash %}
docker run \
-d \            # detached mode (container runs as a background job)
-p 80:80 \      # map the port number of the service in the container to the exposed port of the container
-v /$(pwd)/public/:/var/web/assets/  # mount your local directory (with the pwd command) in the container where root is specified
myDockerImage
{% endhighlight %}

This way code can be developed in a tightly-loop environment that more closely mirrors the production environment. 
