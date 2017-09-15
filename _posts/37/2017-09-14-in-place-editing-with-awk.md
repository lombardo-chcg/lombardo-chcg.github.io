---
layout: post
title:  "in-place editing with awk"
date:   2017-09-14 21:17:41
categories: tools
excerpt: "using awk to modify a file directly"
tags:
  - bash
  - unix
  - awk
  - sed
  - grep
  - text
---

It appears one limitation of traditional `awk` is that it does not write back to the source file without using a temp file.

It is good practice to write to a temp file; it is the way I prefer to use the `sed` command as well.

However in certain cases, it would be just so much more convenient to write directly to a source file.

For example, say you have a repo, that has a file which keeps track of the "version" of the code.  Say there's a script which builds the code, creates a docker image, tags the image, and pushes the image to a docker repository.  Let's say we also want to increment the version used in the tagging as part of the script.

in `version.file`:
{% highlight bash %}
1
{% endhighlight %}

our base command to increment the version:
{% highlight bash %}
awk '{print $1 + 1'} version.file
# 2
{% endhighlight %}

now we just need to `echo` the output of that command back to the source file:
{% highlight bash %}
echo "$(awk '{print $1 + 1'} version.file)" > version.file
cat version.file
# 2
{% endhighlight %}

Here's a fun challenge: write a `awk` script which increments major, minor or revision version number (aka `0.0.1`) based on a rule set. 
