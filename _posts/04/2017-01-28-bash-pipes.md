---
layout: post
title:  "bash pipes"
date:   2017-01-28 17:51:34
categories: tools
excerpt: "making fun little programs with the pipe"
tags:
  -
---
The `|` symbol in bash is known as a pipe.  It is simple but powerful.  It is used to pipe the output of one process into the input of another.  In this way it reminds me of the functional programming style of writing simple, single purpose functions, and chaining them together to perform complex tasks.

On the command line it becomes easy to write simple programs using the pipe.

For example, let's get the disk usage for all the files in the `/Downloads` directory, then sort them from high to low.  We will pipe the output of `du` aka disk usage into the `sort` tool.
{% highlight bash %}
du -h ./Downloads | sort -hr
{% endhighlight %}
`-h` for human-readable output (aka megabytes instead of bytes)
`-r` for reverse sort (high to low)

if the output is too much to see on one screen, send it into `less` so you can scroll thru it.
{% highlight bash %}
du -h ./Downloads | sort -hr | less
{% endhighlight %}

--

Another useful chain is piping stuff into `grep`.

See if a file called "my_file" exists in the current directory:
{% highlight bash %}
ls | grep my_file
{% endhighlight %}
*`find . -name my_file` also does this job, but I prefer grep as I don't have to use wildcards for partial matching.*

Anything that produces a text output can be fed into `grep` in this manner.  

--

When I'm writing these blog posts, I run the Jekyll server in the background to check formatting before I commit and push.  This means I have to locate the process and kill it when I'm done.  That is a great example of piping output to get a result.  

Here's the chain in plain English:

* print list of all running processes
* find the ones that contain "jekyll"
* filter out the `grep` process from the list, leaving only the actual jekyll process
* get the pid for the jekyll process which is located in the 2nd column of the whitespace-separated output
* kill that process

and in bash:
{% highlight bash %}
# WARNING! don't run kill commands copied from the internet on your system!

ps aux | grep jekyll | grep -v grep | cut -d' ' -f2 | xargs kill -9
{% endhighlight %}

--

Piping is a great way to learn the basics of programming pipelines and connecting inputs to outputs.  A simple but powerful idea that can be taken to great heights.
