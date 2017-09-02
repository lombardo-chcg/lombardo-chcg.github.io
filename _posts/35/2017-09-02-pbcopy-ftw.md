---
layout: post
title:  "pbcopy ftw"
date:   2017-09-02 09:12:15
categories: tools
excerpt: "pipe terminal output to the clipboard"
tags:
  - unix
  - bash
---

`pbcopy` is a great tool on Apple systems that accepts standard input and puts on on the clipboard, so it can be pasted into another program.

For example,
{% highlight bash %}
echo "put me on the clipboard" | pbcopy
{% endhighlight %}

Now the `echo`'ed text will be on the clipboard.  

Here's a bash function for [generating a new password](/mixed-bag/2017/03/27/better-passwords.html) and having it wind up on the clipboard:

{% highlight bash %}
function hexPassword() {
  if [[ ! $1 =~ [0-9]+ ]];
    then
      echo -e "must enter a password length as argument\nsample usage: hexPassword 8"
    else
      echo -e "fun fact: each hexadecimal digit represents four binary digits\n"
      password=$(openssl rand -hex $1)
      echo $password | pbcopy
      echo "generated password $password is now on the clipboard"
  fi
}
{% endhighlight %}

This can be done on Linux with a similar tool such as `xclip`.
