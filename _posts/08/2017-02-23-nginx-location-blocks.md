---
layout: post
title:  "nginx location blocks"
date:   2017-02-23 21:37:03
categories: environment
excerpt: "understanding nginx location block syntax"
tags:
  - nginx
---

Nginx has tons of options for handling uri requests inside a location block.  

To match an exact route, use the `=` sign.
{% highlight bash %}
location = /exact-match.html {
  # do stuff here
}
{% endhighlight %}
To match a route prefix, just drop the `=`
{% highlight bash %}
location = /users {
  # do stuff here
}
{% endhighlight %}
This will match any request that starts with `/users`, i.e. `/users/summary`

You can also do regex-style pattern matching, helpful for serving up static assets:
{% highlight bash %}
location ~* \.(css|scss|less|)$ {
  # do stuff here
}
{% endhighlight %}
The `~*` matches regardless of case, i.e. `STYLES.CSS` or `styles.css`.  To do exact matching (case sensitive), just drop the `*`.
