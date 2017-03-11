---
layout: post
title:  "hello world, nginx+docker edition (part 2)"
date:   2017-03-11 11:29:07
categories: ops
excerpt: "finishing hello world with nginx and docker"
tags:
  - nginx
  - docker
---

[In Part 1]({{ full_base_url }}/ops/2017/03/11/hello-world,-nginx+docker-edition-(part-1).html) we set up our basic structure and Nginx configuration.  Now let's get our hands dirty with the Docker config.

First we need to set up our Dockerfile.  Docker operates like a layer cake of code, starting with a foundational layer OS (Linux) and then adds our custom code on top.  The final output is a Docker image, which is basically a blueprint for creating Docker containers.  

I think of Docker containers as little mini-computers that contain all our application code.  By starting a container, we start a capsule of code that runs exactly as specified in our original build process, in the Dockerfile.

Hope that makes sense.  Here's the contents of our `Dockerfile`:
{% highlight bash %}
FROM nginx

COPY /conf/nginx.conf /etc/nginx/nginx.conf

COPY /src /src
{% endhighlight %}

There are 3 layers in this cake:
* start with the [nginx base layer image](https://hub.docker.com/_/nginx/)
* copy our `nginx.conf` file to `/etc/nginx` directory of the Nginx image
* copy over our custom source code

And that's it.  We now have a bare-bones Nginx server recipe ready to be built and deployed.  Let's do that in a Docker Compose file.

Docker Compose files are really meant for running multi-container applications, but it will be nice to see how they work using this basic example.

In `docker-compose.yml`:
{% highlight bash %}
version: '2'

services:
  hello_world:
    build: .
    ports:
     - "80:80"
{% endhighlight %}

Here we are using Docker Compose version 2.  We establish a service (aka a Docker container) called `hello_world`.  This the image needed to start this service does not exist yet, so we need to build it.  The `build .` tells Docker Compose to run the code in the Dockerfile contained in our current working directory.  Then we need to expose the port.  Nginx runs on port 80 by default, so we just need to map that port to port 80 of the Docker container so we can access it.

And that's it.  Now we can start our service and test it out.

{% highlight bash %}
docker-compose up
{% endhighlight %}

You should see some terminal output showing the steps (or layers) that Docker is adding to the image during the `build` step.  Once you see the output that says `Attaching to hello_world` or something like that, you are ready to test.

(Assuming you are using Docker for Mac) In the browser navigate to `http://localhost:80/`.   You should see the hello world message!

Now hit the api from your terminal:
{% highlight bash %}
curl http://localhost:80/api/
#=> { "message": "hello world" }
{% endhighlight %}

Nice!  A fully functional Docker container in like 15 minutes.  Hope you enjoyed the tutorial.
