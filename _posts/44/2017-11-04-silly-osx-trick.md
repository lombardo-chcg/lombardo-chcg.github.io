---
layout: post
title:  "silly osx trick"
date:   2017-11-04 17:39:14
categories: tools
excerpt: "fun trick to use in bash scripts"
tags:
  - bash
  - unix
  - apple
---

Here's a cool trick to use in a script, especially one running the the background which needs to alert on some type of event:

{% highlight bash %}
osascript -e 'display notification "That task just finished" with title "Update from background script!"'
{% endhighlight %}

More on the [Open Scripting Architecture](https://developer.apple.com/library/content/documentation/AppleScript/Conceptual/AppleScriptX/Concepts/osa.html)
