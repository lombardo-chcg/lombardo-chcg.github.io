---
layout: post
title:  "secure http"
date:   2017-04-04 22:07:31
categories: web-programming
excerpt: "understanding https"
tags:
  - http
  - security  
---

In light of the [recent activity in the Federal Gov't](https://techcrunch.com/2017/03/28/house-vote-sj-34-isp-regulations-fcc/) to repeal broadband privicy restrictions, I thought it wise to look into secure internet communication.

HTTP is a text-based message protocol which is inherently unsafe.  By adding a layer of encryption before a message is sent over public networks, a better level of security can be attained.

*note: most of this information was gleaned from [Scott Allen's](http://odetocode.com/) HTTP course on Pluralsight.  shout out to Scott*

* Secure HTTP or HTTPS uses the cryptographic protocol TLS, previously known as SSL
* the default port for HTTPS communication is 443 (HTTP is 80 as you may recall)
* HTTPS adds a security layer to network protocol stack

Standard HTTP Web transmission stack:
{% highlight bash %}
application -> transport -> network -> datalink
   (http)   ->   (tcp)   ->  (ip)   -> (ethernet)
{% endhighlight %}

HTTPS transmission adds the Secure Sockets Layer (SSL) aka the Transport Layer Security (TLS) between the application and transport layers:

{% highlight bash %}
application -> encryption -> transport -> network -> datalink
   (http)   -> (SSL/TLS)  ->   (tcp)   ->  (ip)   -> (ethernet)
{% endhighlight %}

Before the message hits the transport layer, it is encrypted.  The headers, message body, url path, url query string, cookies are all encrypted.  The host name is NOT encrypted.

This prevents network snoopers using a tool like Wireshark from reading messages as they travel across wifi (I tried!).

An HTTPS message is encrypted using a cryptographic certificate obtained from the server during the initial handshake between the client and the server.

What is the tradeoff?  SSL is computationally expensive due to the encoding and decoding of messages.  

For more on current events and how to communicate safely online, [check out this stream of tweets from @SarahJamieLewis](https://twitter.com/SarahJamieLewis/status/846874266322665472)
