---
layout: post
title:  "bash: play nice with others"
date:   2017-05-22 20:15:27
categories: tools
excerpt: "using output from other interpreters in bash scripts"
tags:
  - bash
  - ruby
---

bash is a great tool for many things, but it also falls short in many areas when compared to other scripting tools such as Ruby or JavaScript.  For example, iterating collections or performing math operations.

Here's the goal of this post: capture output from a Ruby program and use it in a bash script.

For this we can just lean on the [`IO` class](http://ruby-doc.org/core-2.0.0/IO.html) and its `puts` (put string) method.  `puts` writes to standard out.  This is perfect: in our bash script, we can evaluate a ruby program that `puts`, and capture the output in a variable.

example.rb:
{% highlight ruby %}
puts "hi from ruby"
{% endhighlight %}

example.sh (don't forget the `chmod`!):
{% highlight bash %}
#!/bin/bash

rubyOutput=$(ruby example.rb)

echo "bash here, dropping some ruby: $rubyOutput"
{% endhighlight %}

{% highlight bash %}
./example.sh

# => bash here, dropping some ruby: hi from ruby
{% endhighlight %}

Just for fun I also tried this with JavaScript and Scala and both worked perfectly.
