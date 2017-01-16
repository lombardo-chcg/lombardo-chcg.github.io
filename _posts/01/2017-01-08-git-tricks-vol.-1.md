---
layout: post
title:  "git tricks vol. 1"
date:   2017-01-08 13:24:06
categories: tools
excerpt: "nifty trick to enhance git work"
tags:
  - git
---

Question: I have branched off master to work on a feature, and I have 3 commits made on the feature.  However I have gone off into the weeds on my feature.  I want to save my work, but I also want to go back to the first commit on my feature, and start a new branch to test an idea.  Can I do this?

starting point:
{% highlight bash %}
   commit1----commit2----commit3  [feature]
  /
commitA----commitB [master]
{% endhighlight %}

Answer: this is Git, of course you can.

{% highlight bash %}
# create the branch
git branch <new-branch> <commit-SHA-where-you-want-to-branch-from>

# create and checkout
git checkout -b <new-branch> <commit-SHA-where-you-want-to-branch-from>
{% endhighlight %}

new git status:
{% highlight bash %}
     commitZ  [new-branch]
    /
   commit1----commit2----commit3  [feature]
  /
commitA----commitB [master]
{% endhighlight %}

Cool.
