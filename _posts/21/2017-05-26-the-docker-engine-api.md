---
layout: post
title:  "the docker engine api"
date:   2017-05-26 19:49:48
categories: tools
excerpt: "going under the hood with docker"
tags:
  - docker
  - api
  - REST
---

Underneath the powerful CLI familiar to any Docker user lies the mysterious Docker daemon.  If you've used Docker on a Linux machine you may be familiar with the `dockerd` command which starts the Docker daemon.  It turns out this daemon is really just a server that takes HTTP requests.

[*read more here about the daemon*](https://docs.docker.com/engine/docker-overview/#the-docker-platform)

This docker "server" process offers a RESTful interface, which is the interaction point between the docker software and its users.  The familiar Docker CLI sits on top of this REST interface, so it is usually invisible.  but it is also possible to communicate directly with the daemon thru standard HTTP calls.

Running `docker version` will tell you the version of the Server you are running.  You can use this version number to communicate with the daemon directly.  (just look for the version number under `Server` when you run `docker version`)

Let's see a few examples.  (I'm piping them into `jq` for readability)

--

#### List all images
Docker CLI command:
{% highlight bash %}
docker images
{% endhighlight %}

Docker REST API request:
{% highlight bash %}
curl --unix-socket /var/run/docker.sock http:/v1.27/images/json | jq
{% endhighlight %}

--

#### List all running containers
Docker CLI command:

{% highlight bash %}
docker ps
{% endhighlight %}

Docker REST API request:
{% highlight bash %}
curl --unix-socket /var/run/docker.sock http:/v1.27/containers/json | jq
{% endhighlight %}

--

#### Create and Run a container
`docker run` does this from the Docker CLI in a single shot.  In HTTP/REST we can create and then start it using 2 different requests

Docker CLI command:

`docker run --name my_nginx -p "80:80" nginx`

This will start an Nginx server and expose port 80 on the host, mapping it to port 80 on the container.

Docker REST API:

(we pass `Image` and `PortBindings` as JSON, and the `name` of the container as a query param)
[Check out the full API here](https://docs.docker.com/engine/api/v1.24/#3-endpoints)
{% highlight bash %}
curl --unix-socket /var/run/docker.sock \
    -H "Content-Type: application/json" \
    -d '{"Image": "nginx", "PortBindings": { "80/tcp": [{ "HostPort": "80" }] }}' \
    -X POST http:/v1.27/containers/create?name=my_nginx
{% endhighlight %}

Start the container:
{% highlight bash %}
curl --unix-socket /var/run/docker.sock -X POST http:/v1.27/containers/my_nginx/start
{% endhighlight %}

Now if you visit `localhost:80` (or wherever your dockerhost lives) in a browser you will see the standard Nginx welcome message.  

Amazing in its simplicity and elegance.  I am consistently blown away by the power of Docker, but this time I am impressed by the elegance, simplicity and power of its HTTP interface.

In a future post I will explore the `unix-socket / docker.sock` part of the commands and see what that business is all about.
