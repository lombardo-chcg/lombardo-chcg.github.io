---
layout: post
title:  "intro to cron"
date:   2017-07-02 23:34:27
categories: tools
excerpt: "a basic look at the cron utility for task scheduling"
tags:
  - bash
  - docker
---

> Cron is the name of program that enables unix users to execute commands or
scripts (groups of commands) automatically at a specified time/date.
[-*http://www.unixgeeks.org/security/newbie/unix/cron-1.html*](http://www.unixgeeks.org/security/newbie/unix/cron-1.html)

I found a use case for `cron` today but its always good to learn the fundamentals before running.

So let's experiment in a basic Linux sandbox environment with `cron` installed:
{% highlight bash %}
docker run -it lombardo/ubuntu-sandbox bash
{% endhighlight %}

`ls etc` and you will see a bunch of `cron` listings.  the `.daily` `.monthly` etc are directories where scripts can be placed that will run as expected based on the directory name.

For finer grain control a user can supply their own `crontab`.  According to the man page, cron jobs are driven by tables hence the `crontab` name.  These custom files can be placed in the `cron.d` directory.

Let's create a custom cron job.  For this experiment let's create a log file where we can log the results of our scheduled task:

{% highlight bash %}
touch /var/log/cron.log
{% endhighlight %}

Now let's have a look at the existing `crontab` file:

{% highlight bash %}
vi etc/crontab
{% endhighlight %}

We see this is a system-wide crontab, and also that any changes we make will be loaded up automatically.  that's cool.

At the bottom of this file, we see some table listings such as:
{% highlight bash %}
# m  h  dom mon dow user  command
  17 *  *   *   *   root  cd / && run-parts --report /etc/cron.hourly
{% endhighlight %}

The `17 *    * * *` is the schedule declaration specifies when the job will run.  In this case, at minute 17 every hour (hence this is the command that runs jobs in the `cron.hourly` directory.)

The `cron` scheduling system is fairly cryptic.  I found this resource to be very helpful: [https://crontab.guru](https://crontab.guru).

Let's add our own "job" that runs every minute.  At the bottom of the file use vim's insert mode to add the following line:

{% highlight bash %}
* * * * * root echo "$(date): hola mundo" >> /var/log/cron.log 2>&1
{% endhighlight %}

Exit vim.  Back at the terminal, let's start the `cron` utility

{% highlight bash %}
cron
{% endhighlight %}

Let's wait 60 seconds then inspect the contents of our log file:

{% highlight bash %}
cat var/log/cron.log
# Mon Jul  3 04:54:01 UTC 2017: hola mundo
{% endhighlight %}

There's our output.  Keep checking back.  As long as the container is running, new lines will be logged every minute.
