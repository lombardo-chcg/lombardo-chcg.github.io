---
layout: post
title:  "from the system to the browser"
date:   2017-03-06 21:40:35
categories: environment
excerpt: "accessing environmental variables from a javascript browser application"
tags:
  - javascript
  - nginx
  - web-programming
---

**Given:** I have a javascript client app that is being deployed as a Docker container.  I need the application code to be able to access environmental variables at runtime.  My JS application code is served up as static content by Nginx, which is running in the container.  

**Unknown:** How the heck do I access environmental variables from browser code?

**Known:** The browser can make HTTP calls, and Nginx can intercept these calls.  System variables can be accessed thru Nginx configuration files ([using the confd utility, for example](https://github.com/kelseyhightower/confd/blob/master/docs/templates.md#getenv)).

**Solution:** setup a custom Nginx location directive, which serves up a JSON payload that contains the desired system variable.

Nice.  Let's run thru the code.

First, set up a custom "endpoint" inside the Nginx configuration file using a location block.  (location blocks tell Nginx how to handle requests to the specified resource path).
{% highlight bash %}
location /api/json-response/ {
  return 200 {% raw %}'{{getenv "CUSTOM_JSON"}}'{% endraw %};
}
{% endhighlight %}

Next, pass in the `CUSTOM_JSON` environmental variable at Docker runtime (example here using a Docker Compose file).  These variables can then ...ahem... 'vary' per environment.
{% highlight bash %}
my_application:
  image: dockerhub/my_image
  ...
  environment:
    CUSTOM_JSON: "{\"code\":\"200\", \"message\": \"custom json ftw\"}"
{% endhighlight %}

Then start up your container.  Now you can access the system variable thru an HTTP call:
{% highlight bash %}
curl http://dockerhost:86/api/json-response/
#=> {"code":"200", "message": "custom json ftw"}
{% endhighlight %}
and so can your JS app.

Of course, if you find yourself doing this, you should ask "why does my JS app need to know about system level variables?"  But still, a fun little experiment.
