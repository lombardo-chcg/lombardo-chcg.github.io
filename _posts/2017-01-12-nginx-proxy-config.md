---
layout: post
title:  "nginx proxy config"
date:   2017-01-12 21:03:49
categories: environment
excerpt: "how to proxy requests to an nginx server"
tags:
  - nginx
---

Nginx is one of those hidden technologies that powers the modern web.  I have read that around 20% of all websites are served up with Nginx.

I've been working on modifying the Nginx config file for an existing application and I've been learning some cool stuff.  

First off, the nginx.conf file is a straightforward configuration file.  The syntax reminds me of a scripting language but the block layout reminds me of a yml config file.

One important feature is the ability to proxy requests, meaning the nginx server is a "middle-them" that sits between two systems that are communicating (such as a browser and a web application) and handles the request routing.  

Wanted to share a gotcha about this config file.

To set up an nginx proxy, use the `location` block with the `proxy_pass` directive.

example 1
{% highlight bash %}
location /api/endpoint {
    proxy_pass http://back_end_server/;

    # note the slash ---------------/\
}
{% endhighlight %}

example 2
{% highlight bash %}
location /api/endpoint {
    proxy_pass http://back_end_server;

    # note, no slash ---------------/\
}
{% endhighlight %}

Turns out there is a big difference with the slash.

Consider a request made to `http://exposed_server.com/api/endpoint/resource/42`

Example 1 (with trailing slash) will route the request to `http://back_end_server/resource/42`
Example 2 (no trailing slash) will route the request to `http://back_end_server/api/endpoint/resource/42`

Most likely option 1 is what you'll want but both are available.

As an Nginx newb, it took me a good chunk of time reading the server logs before this dawned on me.  Note to self...READ THE DOCS.  You know better.
