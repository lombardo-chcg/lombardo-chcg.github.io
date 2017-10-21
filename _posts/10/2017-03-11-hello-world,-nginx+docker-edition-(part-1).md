---
layout: post
title:  "hello world, nginx + docker edition (part 1)"
date:   2017-03-11 11:06:50
categories: web-dev
excerpt: "basic hello world action using nginx and docker"
tags:
  - nginx
  - docker
---

Sat down at the keyboard today with a desire to get back to basics.  

> "In accordance with the ancient traditions of our people, we must first build an app that does nothing except say Hello world."
> [*-Facebook's React Native tutorial*](https://facebook.github.io/react-native/docs/tutorial.html)

So today I'm going to do a quick run thru of building a web server that returns 'hello world' as html and json, using Nginx and Docker under the covers.

[*please install Docker before proceeding*](https://docs.docker.com/engine/installation/)

-

Let's run some commands to get our project structure set up:
{% highlight bash %}
mkdir hello_world_docker_nginx
cd hello_world_docker_nginx
touch Dockerfile docker-compose.yml
mkdir src conf
touch src/index.html conf/nginx.conf
{% endhighlight %}

Here's the basic structure of the project after the preceeding commands:
{% highlight bash %}
├── Dockerfile
├── conf
│   └── nginx.conf
├── docker-compose.yml
└── src
    └── index.html
{% endhighlight %}

Now lets toss some basic HTML in the `index.html` file:
{% highlight html %}
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>hello world</title>
  </head>
  <body>
    <h1>hello world</h1>
  </body>
</html>
{% endhighlight %}

Cool. Now we need to set up our `nginx.conf` file.  These suckers can be massively complicated but we are going to do the bare minimum.
{% highlight lua %}
events { }
http {
    server {
      location /api/ {
        return 200 '{ "message": "hello world" }';
      }

      location / {
        root /src;
      }
    }
}
{% endhighlight %}
What we are doing here is setting up an HTTP server with 2 "locations" or endpoints:

* `/api/` returns a JSON payload with a 200 status
* `/` the root which serves up our `src` directory, which by default serves the `index.html` file.  Therefore we don't need to specify the `index.html` file here.
* the events block is required by Nginx but I won't cover that here.  [Read more if you desire.](http://nginx.org/en/docs/ngx_core_module.html#events)

[Continued in part two!](/web-dev/2017/03/11/hello-world,-nginx+docker-edition-(part-2).html).html)
