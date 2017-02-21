---
layout: post
title:  "on the express train"
date:   2017-02-20 21:36:41
categories: web-programming
excerpt: "working with the express http server framework in node"
tags:
  - javascript
  - node
  - api
---

It's been a busy few days!  I've been doing some traveling and also getting prepared for my first ever tech talk at the [Chicago JavaScript Meetup Group](https://www.meetup.com/js-chi/) tomorrow night.

The talk is on Pact Testing.  I created a basic frontend/backend example to show how the consumer producer pattern works.  In doing so I took the chance to try the Express framework for NodeJS.  

Express follows in the Ruby Sinatra pattern of being a solid, bare-bones http server that can be as simple or as complex as the user needs.   It seems every language now has their own "Sinatra".  I have also used Scalatra (Scala) and Spark (Java).

Express is bare bones to the max.  One even needs to bring in an external library in order to parse http request bodies.

But it is still super-simple.  Here's all the code you need to get up and running with a web server that can handle post request data:

{% highlight javascript %}
var bodyParser = require('body-parser');
var express = require('express');

var app = express();
var jsonParser = bodyParser.json();

app.post('/demo', jsonParser, function(req, res) {
  console.log(req.body);
});

app.listen(3000, function () {
  console.log('Post endpoint available at http://localhost:3000/demo')
});
{% endhighlight %}

full code example here: [https://github.com/lombardo-chcg/pact_testing_for_frontend_devs](https://github.com/lombardo-chcg/pact_testing_for_frontend_devs)
