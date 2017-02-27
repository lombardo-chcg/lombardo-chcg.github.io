---
layout: post
title:  "don't forget your ps2"
date:   2017-02-26 20:15:55
categories: tools
excerpt: more bash prompt customization
tags:
  - bash
---

Most people who've tinkered with customizing their bash prompt are familiar with the `PS1` variable which controls what the prompt displays. ([read more about `PS1` here]({{ full_base_url }}/tools/2017/02/17/custom-bash-prompt-action.html))

I learned there are actually 3 additional `PS` variables available for customization.

`PS2` controls the prompt during a multiline request.  For example when passing a bunch of arguments to a script.

Try entering `echo \` in your prompt.  the next line should be a `>` symbol, indicating the interpreter is awaiting further input before running the command.  (the `\` char tells the interpreter to offer a new line to the user)

The `>` symbol is a default, but it can be customized just like PS1.

Try this:
{% highlight bash %}
export PS2="awaiting additional instructions...> "
echo \
{% endhighlight %}
bash will offer you a new line with your new continuation message.

`PS3` doesn't seem terribly useful and `PS4` seems a little more so.  I'm not going to address them now but [you can read more here if interested](http://www.thegeekstuff.com/2008/09/bash-shell-take-control-of-ps1-ps2-ps3-ps4-and-prompt_command/).

--

PS: speaking of all this `PS` business....I've missed a few posts over the last 2 weeks.  What a bum.  Life's been crazy busy, but I'm going to continue the effort!
