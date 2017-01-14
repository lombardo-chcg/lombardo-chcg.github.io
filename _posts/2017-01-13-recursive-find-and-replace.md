---
layout: post
title:  "recursive find and replace"
date:   2017-01-13 22:47:03
categories: tools
excerpt: "using bash to hunt and replace text in multiple files"
tags:
  - bash
  - sed
---

Problem: I have a directory full of nested directories, which are themselves full of application code files.  At runtime, I need to do a find-and-replace of some strings in these files.

Solution: use the bash powertools `find` and `sed`.  Oh an we need a lil help from `xargs` to read the stream of file names from `find` stdout and pass them as arguments into `sed`.

gnu linux syntax:

{% highlight bash %}
# how it works
find <directory_location> -type f | xargs sed -i 's|<text_to_match>|<replacement_text>|g'

# example
find src/ -type f | xargs sed -i 's|http://oldurl.com|http://newurl.net|g'
{% endhighlight %}

on mac, in-place `sed` commands need an extra empty string before the substitute command (`-i ''`).  this goes back to the lineage difference where mac is bsd based and linux has the gnu sed.  example:
{% highlight bash %}
find src/ -type f | xargs sed -i '' 's|http://oldurl.com|http://newurl.net|g'
{% endhighlight %}
