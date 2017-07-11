---
layout: post
title:  "knock knock"
date:   2017-07-10 19:55:54
categories: "security"
excerpt: "sharing some interesting activity from a web service log"
tags:
  - scalatra
  - docker
  - postgres
---

So my [previously discussed docker-scalatra project](/search?term=scalatra) Scrabble-helper is currently live on AWS: [ec2-13-58-197-69.us-east-2.compute.amazonaws.com/words/chicago](http://ec2-13-58-197-69.us-east-2.compute.amazonaws.com/words/chicago).  I was reviewing the activity logs and I found something very interesting.  

It appears someone is trying to hack me!

In the logs, I found a groups of consecutive requests from a user-agent called `Jorgee`, which a [quick Google search revealed](https://community.spiceworks.com/topic/241169-anybody-know-what-jorgee-is) is a "backdoor tester" agent.

This Jorgee agent basically probes an exposed web service, looking for endpoints it can exploit.  In my case here are a list of endpoints it was searching for:

{% highlight bash %}
...
/db/phpmyadmin/
/db/phpMyAdmin/
/sqlmanager/
/mysqlmanager/
/php-myadmin/
/phpmy-admin/
/mysqladmin/
/mysql-admin/
/admin/phpmyadmin/
/admin/phpMyAdmin/
/admin/sysadmin/
/admin/sqladmin/
...
{% endhighlight %}

For each endpoint, it sent a `HEAD` http request to check the return status.  (a HEAD request is basically a GET without the body...aka...the headers).

Since I am not running any PHP, phpMyAdmin or mySQL these requests are getting 404 responses all day.

Turns out this type of thing is extremely common and happens to basically all web servers.  And of course the request IP address being used is registered in Ukraine, a proxy no doubt.

Just another example of the importance of being secure online.  If a backdoor exploit bot can find my tiny web service in the vast ocean of AWS, then no web service is really safe.

Perhaps a future post on how to handle these requests, so my server doesn't have to waste cycles creating 404s for this crap.
