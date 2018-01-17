---
layout: post
title:  "diff and patch"
date:   2018-01-16 21:06:11
categories: tools
excerpt: "exploring version control with unix tools"
tags:
  - bash
  - unix
  - git
---

Git is easily one of the best tools for software development.  However, this tool is only 12 years old.  What were some of the tools that we used for version control before git?

Unix has 2 tools which can be used for "version control": `diff` and `patch`.  Here's a quick demo:

{% highlight bash %}
echo -e "same content\nsame content\ndifferent content file1\nsame content" >> file1.txt
echo -e "same content\nsame content\ndifferent content file2\nsame content" >> file2.txt
{% endhighlight %}

Now we have 2 separate files that contain the same text less one character.  We can use the `diff` tool to confirm:

{% highlight bash %}
diff file1.txt file2.txt
{% endhighlight %}

A standard developed years ago around using the `-u` flag to `diff` in order to produce "unified" output.  This flag provides "context" around the diff, meaning it shows surrounding lines of the diff.  There's also a `-c` flag which shows the diffs in separate blocks.

Think of the `-u` flag to be the same as viewing a "unified diff" in a modern web tool like GitHub or BitBucket.

The `-c` flag is like a "side by side" view in GitHub or BitBucket.

The `-u` output is what we will use as input to our `patch` tool.  Here's how it works:

{% highlight bash %}
diff -u file1.txt file2.txt > diff.patch

# now we apply the patch to file1.txt

patch file1.txt < diff.patch
{% endhighlight %}

Viewing `file1.txt` will now reveal that its contents have been changed: it is now identical to file 2.  We have successfully applied a patch.

In the days before version control, I can imagine developers passing around these patch files while working on software together. 
