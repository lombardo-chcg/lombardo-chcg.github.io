---
layout: post
title:  "custom bash prompt action"
date:   2017-02-17 11:01:16
categories: tools
excerpt: "understanding what happens when a new prompt appears"
tags:
  - bash
---

In a terminal session, every time a foreground process finishes a new prompt appears.

What is happening to cause this new prompt to appear?

There are 2 bash variables controlling this process.  One is `PS1`:

{% highlight bash %}
echo $PS1
#=> \[\e[0;34m\]\W\[\e[0m\] [\[\e[0;32m\]master\[\e[0m\]] $:
{% endhighlight %}

This variable contains the content that is displayed at your prompt.  In my case the output is the current path and the git branch (if there is one) along with colors:

{% highlight bash %}
lombardo-chcg.github.io [master] $:
{% endhighlight %}

There is another variable called `PROMPT_COMMAND` [which is evaluated every time](http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x264.html) just before the value of the `PS1` variable is printed out.  This can be used to echo the current time or check to run other commands you'd like to run before printing PS1.  I imagine a fun use of `PROMPT_COMMAND` would be to check the exit status from the previous command, and if it is greater than 1 do something helpful like print the command again or provide feedback based on the exit code. 
