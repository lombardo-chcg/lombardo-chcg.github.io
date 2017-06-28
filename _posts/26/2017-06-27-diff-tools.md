---
layout: post
title:  "diff tools"
date:   2017-06-27 22:31:31
categories: tools
excerpt: "diff'ing files from the terminal"
tags:
  - bash
  - git
  - colordiff
---

I had a great use case for the Unix `diff` tool, today, which is used to show differences between files.

It's a total power tool and there are tons of ways to use it.  The `man` page is excellent as usual [and here's another nice resource](https://www.computerhope.com/unix/udiff.htm).

Using the `-y` or `--side` flag does a side-by-side output when comparing files.  Take it one step further with the `colordiff` wrapper which provides some nice color highlighting on top of the standard `diff` output.  `brew install colordiff` to get rolling on OSX.

As with most Unix tools of this nature, `diff` can also rip thru a directory tree and return a summary output of the  files that have diff's:

{% highlight bash %}
diff -qr dir1/ dir2/
# same as
diff --brief --recursive dir1/ dir2/

# Files dir1/file1 and dir2/file1 differ
# Only in dir2/: fancy-dir2-file
{% endhighlight %}
