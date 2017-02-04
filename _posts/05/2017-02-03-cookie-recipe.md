---
layout: post
title:  "cookie recipe"
date:   2017-02-03 22:07:20
categories: web-programming
excerpt: "what makes an http cookie?"
tags:
  - http
---

Innovation is often driven by pragmatism.  Such is the case for the written word, [which started around 3500 BC in Mesopotamia as a way to keep track of basic trade transactions](https://edsitement.neh.gov/lesson-plan/cuneiform-writing-system-ancient-mesopotamia-emergence-and-evolution#sect-background).  Only later were writing systems embellished and adapted to tell stories and pass down artistic expression through generations.

Http cookies were invented in the early days of the internet (1994) for to meet a similar need: [the development of an e-commerce website](https://en.wikipedia.org/wiki/HTTP_cookie).  This foundational internet technology is one of the key players that help today's web applications provide users with rich, interactive experiences, using just a browser.

The basic use of a cookie is to provide state to the inherently stateless http protocol.  Cookies allow a web app to log users in, then to keep track of who a user is, what they have access to and what they don't have access to.  Cookies can also be used to gather information about a user's browsing habits and feed the modern beast known as "big data", giving companies insight and allowing them to market to a customer, or do other mischievous things.

So what makes up a cookie?

A cookie is another example of the key-value data structure that is so prevalent on the web.  When a request is made to a web server that wants to set a cookie in a users browser, the server replies to the http request with a `Set-Cookie` header.  Open up your chrome developer tools network tab, click on XHR, log into some website and click on the request that says "login", "sessionUpdate", "authorization", "token", etc., and you'll see what I mean.

{% highlight bash %}
Set-Cookie: authorization=J8asd7fkASDFikhasdfi7Dfjkhasd8f7asdf7;
{% endhighlight %}

`authorization` is the name of the cookie and `J8asd7fkASDFikhasdfi7Dfjkhasd8f7asdf7` is the value (an encrypted string of text that is decoded by the server who issued it).  The name can be anything and so can the value.  This k/v pair the the only required part of a cookie.

The other common parts you'll see in a cookie are domain, path and expiration.

{% highlight bash %}
Domain=theSiteYouAreOn.com;
Path=/;
Expires=01-Jan-2036 08:00:01 GMT;
{% endhighlight %}

Path simply means which resources on the server require the cookie in question.  A path of `/` means it is good for the entire site.

`HttpOnly` is another common setting on a cookie (it is provided as a flag and not a key-value pair).  This setting prevents the cookie from being available to the browser's JavaScript applications.  This helps to eliminate some  mischievous deeds that can be done with cookies: for example, a malicious piece of code that grabs any available cookies from a http header, and sends them via an xhr post request to another server to be recorded for who knows what purpose.

Full example:
{% highlight bash %}
Set-Cookie: authorization=J8asd7fkASDFikhasdfi7Dfjkhasd8f7asdf7; Domain=theSiteYouAreOn.com; Path=/; Expires=01-Jan-2036 08:00:01 GMT; HttpOnly;
{% endhighlight %}
These are the very basics of cookies.
