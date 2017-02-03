---
layout: post
title:  "rm -rf safety net"
date:   2017-02-02 21:32:21
categories: tools
excerpt: power tools can hurt, unless you have the proper protection
tags:
  - bash
---

bash is a power tool that adds ton of efficiency to software development workflow.  But like any tool, it can be dangerous if misused.

My heart goes out to the employee at Gitlab who recently [decided to remove a production directory](https://docs.google.com/document/d/1GCK53YDcBWQveod9kfzW-VCxIABGiryG7_z_6jHdVik/pub) only to realize a second later it was the wrong directory.  But not before the delete command wiped out over 4gb of production data.

With the bash `rm -rf` command (aka rim raff) it is entirely too easy to blow away an entire directory and all its subdirectories with instant execution and no *are you sure* confirmation.  Like I said, it's a power tool.

If you're like me, you worry about doing something like this someday.  (luckily they don't let me near the production data...)

Today I learned you can add a `-i` flag to the infamous `rm` command to get a confirmation prompt before deleting each file:

{% highlight bash %}
mkdir important_directory
touch important_directory/{1..3}.txt
rm -rfi important_directory
#=> examine files in directory important_directory? y
#=> remove important_directory/1.txt? y
#=> remove important_directory/2.txt? y
#=> remove important_directory/3.txt? y
#=> remove important_directory? y
ls important_directory
#=> ls: important_directory: No such file or directory
{% endhighlight %}

Never know, may save a lot of trouble someday...
