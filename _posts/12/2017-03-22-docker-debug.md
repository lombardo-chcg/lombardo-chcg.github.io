---
layout: post
title:  "docker debug"
date:   2017-03-22 20:45:16
categories: environment
excerpt: "copying files from a failed docker container"
tags:
  - docker
  - debugging
---

Sometimes during a development process its possible produce a Docker image that spawns corrupt containers.  The ones I am talking about fail immediately after being started and not even up long enough `docker exec` into for troubleshooting.

Of course it's always possible to get the logs, even for a failed container, by just grabbing the container ID.

For an example we can use a container from our [Docker-Nginx tutorial from a few weeks ago](/web-dev/2017/03/11/hello-world,-nginx + docker-edition-(part-2).html) that is not actually running.

{% highlight bash %}
docker ps -a
# CONTAINER ID        IMAGE   ....
# 7734cf780980        helloworlddockernginx_hello_world ....
docker logs 7734cf780980
# ... logs will be output here
{% endhighlight %}  

But what if you wanted to download a file from this failed container to inspect it, and see if something went wrong during the Docker build process?   No problem.

Since we know our `nginx.conf` file will be located at path `/etc/nginx/nginx.conf` in the container, we can tell Docker to copy that file to our local directory for inspection.

The command essentially is:

`docker copy containerId:/path/in/container /to/target/path`:

{% highlight bash %}
docker cp 7734cf780980:/etc/nginx/nginx.conf .
cat nginx.conf
# ... nginx file output here
{% endhighlight %}

This is a nice little trick that helped me today with debugging a failed container.
