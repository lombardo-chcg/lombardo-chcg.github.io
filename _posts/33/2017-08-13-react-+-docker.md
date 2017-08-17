---
layout: post
title:  "react + docker, part 1"
date:   2017-08-13 19:38:03
categories: "tools"
excerpt: "dockerizing an app made with facebook's create-react-app tool"
tags:
  - react
  - javascript
  - jsx
  - docker
  - express
  - node
---

[*public repo for this post: https://github.com/lombardo-chcg/dockerized-create-react-app*](https://github.com/lombardo-chcg/dockerized-create-react-app)


--


The [create-react-app](https://github.com/facebookincubator/create-react-app) from Facebook is a fantastic way to kick start a UI project built with React.  I had a use case to deploy a basic React app using AWS EC2 Container Service, so I decided to Dockerize a create-react-app.  Here's how it went down.

Basic workflow

1. create a simple server using [express](https://expressjs.com/) that will serve up the static UI content based based on an http request
2. After finishing up the UI work, use the `create-react-app` build script to create a "productionized" version of the React app
3. combine both pieces into a docker image

### Part 1: basic HTTP server

The create-react-app documentation is some of the best I've seen.  They already included a basic node express server implementation, so we will just build on that to suit our needs.

{% highlight bash %}
mkdir server
cd server
touch main.js

npm init  # defaults are all fine or just enter whatever you want

npm install --save express@4.15.4 express-http-proxy@1.0.6 path@0.12.7
{% endhighlight %}


Now here's a basic Express server:

inside `main.js`:
{% highlight javascript %}
const express = require('express');
const path = require('path');
const proxy = require('express-http-proxy');
const app = express();

app.use(express.static(path.join(__dirname, 'build')));

// I included a dummy proxy handler as I needed it for my use case (grabbing data via XHR)
// Any relative request to `/api` from the React app will be routed to the proxy address, in this case google.
app.use('/proxy', proxy('www.google.com'));

app.get('/', function (req, res) {
  res.sendFile(path.join(__dirname, 'build', 'index.html'));
});

// set up a 404 handler
app.get('*', function(req, res){
  res.status(404).send({ message: "bad request" });
});

app.listen(9000, function() {
  console.log('Server started on port 9000');
});

{% endhighlight %}

Now this node server process is all ready to start handling requests for the single-page app itself, and also for any api calls it may make.

Next time, we'll set up our Dockerfile and build an image.
