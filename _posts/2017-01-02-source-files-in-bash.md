---
layout: post
title:  "source files in bash"
date:   2017-01-02 22:02:17
categories: tools
tags:
  - bash
  - dependencies
---
This blog is made with [Jekyll](https://jekyllrb.com/) which requires some basic formatting of blog post files to display them properly.  Before starting this post, I wrote a little bash script that creates a blank, pre-formatted "post" file and adds the necessary headers for Jekyll to display it.  It's super basic but it was a quick way for me to test the bash scripting skills I've been working on.

(if curious check out the script [here](https://github.com/lombardo-chcg/lombardo-chcg.github.io/blob/master/make-new-post.sh))

As part of this exercise I decided to try sourcing a file into my script.  
Basically this means include some external code that can be run within the script.
This is done in nodeJS and Java with `import` and Ruby with `require`

With bash, it is `source`:
{% highlight bash %}
source scripts/make-post-header.sh
{% endhighlight %}
with the `scripts/make-post-header.sh` providing the relative path to the file.

The most interesting part for me was that while the main script required a
`chmod +x` command be run on it to make it executable, the source file being
brought in did not require a change mode and it still worked within the script.
