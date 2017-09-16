---
layout: post
title:  "express tips"
date:   2017-09-16 17:52:54
categories: tools
excerpt: "prototyping using the node.js express framework"
tags:
  - javascript
  - sinatra
  - http
  - server
---

When standing up a quick HTTP server for an API proof-of-concept or other exploratory purpose, I love to reach for  [Express](https://expressjs.com/).

Express is a minimalist JavaScript web framework.  And that means we get to leverage the fact that the defacto language of the web - JSON - is derived from JavaScript, and working with JSON inside a JS program is about as easy as it gets.  Working with JSON inside of JVM languages, as a comparison, can be a little clunky.

Plus the loosely typed nature of JS means that iteration can be blazing fast.  This comes in handy as API contracts are being defined and modified as part of the workflow.

Here's some nifty middleware that makes web server development with Express even better.

The excellent [morgan](https://github.com/expressjs/morgan) package provides out-of-the-box logging with many formatting options, including "Standard Apache common log output":
{% highlight javascript %}
const morgan = require("morgan");

app.use(morgan('common'));
{% endhighlight %}


--

It also helps to add graceful error handling, to keep the development flow going.

We can use the `app.use` middleware function to mount a 404 handler.

From the docs:
> middleware mounted without a path will be executed for every request to the app.

(this is exactly what the morgan middleware mentioned above is doing as well.)

{% highlight javascript %}
// instead of app.use('/route', function...),
app.use(function (req, res, next) {
  res.status(404).send({message: "resource not found"})
});
{% endhighlight %}

The nice thing there is we just pass a basic JS Object to the `send` method, and it is returned as JSON to the caller.  That's what I mean by being able to quickly leverage the native-ness of JSON within an Express app.

--

Also from the docs:
> You define error-handling middleware in the same way as other middleware, except with four arguments instead of three; specifically with the signature (err, req, res, next):

{% highlight javascript %}
app.use(function (err, req, res, next) {
  console.error(err.stack);
  // hey, what's available on the 'err' object anyways?
  // It is not an Express thing, but rather it comes from the Chrome v8 engine which is implementing the JavaScript standard
  // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error/prototype

  res.status(500).send({message: err.message});
  });
{% endhighlight %}

--

Also the [express-http-proxy ](https://www.npmjs.com/package/express-http-proxy) is a must whenever any front-end work is involved.  (say no to CORS!!)

I recently found a cool user for the `filter` option, to only proxy requests when a condition is met.  From the docs:

> The filter option can be used to limit what requests are proxied. Return true to execute proxy.
> For example, if you only want to proxy get request:

{% highlight javascript %}
app.use('/proxy', proxy('www.google.com', {
  filter: function(req, res) {
     return req.method == 'GET';
  }
}));
{% endhighlight %}

All these and more make Express a great tool to reach for when a quick HTTP server is needed.
