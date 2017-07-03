---
layout: post
title:  "cron part II"
date:   2017-07-03 16:57:20
categories: tools
excerpt: "looking at the cron environment"
tags:
  - bash
---

As a follow up to [yesterday's post](/tools/2017/07/02/intro-to-cron.html) I want to talk about a unique feature of the `cron` utility.

`cron` jobs are run by a daemon, aka a background process.  This means that any commands executed in a `cron` script are not executed in the standard terminal shell.  The env provided is much more stripped down.

A side effect of this is that it becomes tricky to get access to environmental variables while executing a cron task.

Let's build on yesterday's example to see what I mean.

{% highlight bash %}
docker run -it lombardo/ubuntu-sandbox bash
{% endhighlight %}

inside the container let's look at our env:
{% highlight bash %}
printenv

# HOSTNAME=05394d0aa42e
# TERM=xterm
# LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01: .....
# PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# PWD=/
# SHLVL=1
# HOME=/root
# _=/usr/bin/printenv
{% endhighlight %}

As expected.  Now, let's run that same command as a `cron` task and compare the output.
{% highlight bash %}
touch /var/log/cron-env.log
{% endhighlight %}

`vi etc/crontab` and insert the following task:
{% highlight bash %}
* * * * * root printenv > /var/log/cron-env.log 2>&1
{% endhighlight %}

Now start the utility
{% highlight bash %}
cron
{% endhighlight %}

and tail the logs
{% highlight bash %}
tail -f /var/log/cron-env.log
{% endhighlight %}

After 60 seconds the output of the `printenv` command will appear.  It should look much different than the output we saw from the bash prompt.

{% highlight bash %}
# HOME=/root
# LOGNAME=root
# PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
# SHELL=/bin/sh
# PWD=/root
{% endhighlight %}

These are all specific variables set up by the cron utility. (or so says `man 5 crontab`)

This utility is running processes which are not attached to the terminal shell controller by the user.

So let's think...how can we get ENV vars from our normal terminal shell into a `cron` task?  What if we needed to run `cron` in a Docker container, but needed to pass ENV vars in at runtime?

There's a few ways I can think of.  Perhaps I will write about it in the future. 
