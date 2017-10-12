---
layout: post
title:  "timed scripts"
date:   2017-10-11 19:02:27
categories: "tools"
excerpt: "a bash trick to control the lifespan of a script"
tags:
  - bash
  - unix
---

bash provides a [few built in internal variables ](http://tldp.org/LDP/abs/html/internalvariables.html) which can be very useful.  Today I discovered `SECONDS`:

> The number of seconds the script has been running.

For me, this came in handy when I wanted to run a one-time script for 15 minutes, then bail.   

Here's a example running one for 60 seconds:

{% highlight bash %}
#!/bin/bash

while [[ $SECONDS -lt 60 ]]; do
  # do some polling task or whatever
  echo "$SECONDS seconds have elapsed"
  sleep 5
done
{% endhighlight %}

`SECONDS` is available in terminal sessions as well, and contains the number of seconds since the session started. 
