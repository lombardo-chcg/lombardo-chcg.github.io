---
layout: post
title:  "remote control"
date:   2017-05-12 07:32:24
categories: tools
excerpt: "logging into another system via ssh and LAN"
tags:
  - bash
  - networking
---

## On Mac

Enable remote login
{% highlight bash %}
sudo systemsetup -setremotelogin on
{% endhighlight %}

confirm your system username
{% highlight bash %}
whoami
{% endhighlight %}

Confirm your local area network address.  This can be obtained from

Apple menu => System Preferences => Networking

or from the terminal by inspecting the output of `ifconfig` command.  This command produces tons of output so try filtering it with `ifconfig | grep inet`

Now you can connect to your Mac from another system on your local network.

{% highlight bash %}
ssh <system_username>@<system_local_ip>
# for example: ssh sammyjones@192.168.5.40
{% endhighlight %}

Once you enter the password you will have full system access.  (yikes)

to disable:
{% highlight bash %}
sudo systemsetup -setremotelogin off
{% endhighlight %}

## On Ubuntu/Linux

Similar workflow.  To start an ssh server, run this command

{% highlight bash %}
sudo apt-get install openssh-server
{% endhighlight %}

Using the same `ssh user@ip_address` syntax you can now log into your Linux system.
