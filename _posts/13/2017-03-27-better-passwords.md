---
layout: post
title:  "better passwords"
date:   2017-03-27 21:49:31
categories: mixed-bag
excerpt: "generating secure passwords from the terminal"
tags:
  - bash
  - irb
  - ruby
  - openSSL
---

Wise folks know it is bad practice to use the same password across websites.  Or, to use a password that can be cracked in a dictionary attack (`pa33word`, anyone??)

So here's a few quick ways to generate random character passwords from the terminal.

One quick way is with Ruby's [`SecureRandom`](https://ruby-doc.org/stdlib-1.9.3/libdoc/securerandom/rdoc/SecureRandom.html) class and an `irb` terminal session:

{% highlight bash %}
irb
require "SecureRandom"
SecureRandom.base64(12)
# => "dLMdYvXPFXKw7RTK"

SecureRandom.hex(6)
# => "d828f6b3fe6a"
{% endhighlight %}

Your machine may also have come with the OpenSSL library.  This open-source library seems to be a veritable junk drawer of secure communication and encryption tools (meaning that it contains just about everything)

{% highlight bash %}
openssl rand -base64 12
# sgGd0HUUYi+Je5R5

openssl rand -hex 6
# 8fd2eac86994
{% endhighlight %}

It would be easy to alias one of these and pass the desired length as a arg too:

{% highlight bash %}
alias newPassword="openssl rand -base64 $1"
newPassword 12
# moSl4/lAGrRprHUF
{% endhighlight %}

Why is that length 12 password really longer than 12 characters?

**fun fact!**

each base64 digit represents exactly 6 bits of data which is a 4/3 conversion when compared to standard chars.  Said another way, a base64 string with length of 12 which appear as a char string with a length approx 1.33 times longer.
