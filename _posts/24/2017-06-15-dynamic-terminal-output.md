---
layout: post
title:  "dynamic terminal output"
date:   2017-06-15 21:27:38
categories: tools
excerpt: custom formatting based on terminal size
tags:
  - bash
  - docker
---

The output of the `docker ps` command is super useful but can be unwieldy.  Especially on a smaller terminal window.

Turns out there's a cool builtin called `tput` that provides env info on a terminal session.

{% highlight bash %}
tput cols

tput lines
# aka rows
{% endhighlight %}

Here's a "better" `docker ps` for a bash profile:

{% highlight bash %}
function dockerps() {
  {% raw %}[[ $(tput cols) -lt 100 ]] && { docker ps --format "table {{.Names}}\t{{.Ports}}"; return;}{% endraw %}

  {% raw %}[[ $(tput cols) -lt 150 ]] && { docker ps --format "table {{.ID}}\t{{.Names}}\t{{.RunningFor}}\t{{.Ports}}"; return; }{% endraw %}

  {% raw %}docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.RunningFor}}\t{{.Ports}}"{% endraw %}
}
{% endhighlight %}

Now typing `dockerps` as one word will provide more readable output based on the terminal size.
