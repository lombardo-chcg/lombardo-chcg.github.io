---
layout: post
title:  "scalatra+docker (part 1)"
date:   2017-03-16 21:58:08
categories: web-dev
excerpt: "building an http web service with scala and dockerizing it.  in part 1: hello world"
tags:
  - scalatra
  - scala
  - docker
---

[Here's a github repo which will track this project](https://github.com/lombardo-chcg/scalatra-docker)

--

I really enjoyed writing my posts about containerizing an Nginx web service.  So I thought it would be fun to do something a little more advanced and "Dockerize" a Scalatra web server.  In this first post we will just get the basic Hello World app built with Scalatra.

--

# Part 1: Basic Web Server

> "In accordance with the ancient traditions of our people, we must first build an app that does nothing except say Hello world."
> [*-Facebook's React Native tutorial*](https://facebook.github.io/react-native/docs/tutorial.html)

Using Scalatra, we can get a web server up and running quickly, similar to other minimal frameworks like Ruby's Sinatra or JavaScript's Express.

Download Dependencies (OS X specific):
{% highlight bash %}
brew install scala
brew install sbt
brew install giter8
{% endhighlight %}

Let's use Giter8 which provides a quick wizard to bootstrap an app.  Here's the labels I provided:
{% highlight bash %}
g8 scalatra/scalatra-sbt

#> organization [com.example]: com.lombardo
#> name [My Scalatra Web App]: demo-api
#> version [0.1.0-SNAPSHOT]:
#> servlet_name [MyScalatraServlet]: DemoApiServlet
#> package [com.example.app]: com.lombardo.app
#> scala_version [2.12.1]:
#> sbt_version [0.13.13]:
#> scalatra_version [2.5.0]:

#> Template applied in ./demo-api

cd demo-api
{% endhighlight %}

Now we can start the `sbt` cli, compile and run our code.

{% highlight bash %}
sbt
# ... lots of output
> jetty:start
# ... more output
{% endhighlight %}

There will be a TON of output as sbt downloads dependencies and builds the project.  When you see `Server:main: Started`, hit `http://localhost:8080` in the browser and you'll see the standard Scalatra welcome screen.

In the next post we will add JSON support to our server, getting it ready to field requests from our Nginx frontend container.
