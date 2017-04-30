---
layout: post
title:  "public key encryption"
date:   2017-04-30 09:47:31
categories: web-programming
excerpt: "looking under the covers at the basics of public key cryptography"
tags:
  - https
  - Encryption
  - cryptography
  - security
---

Today, a brief look at what makes secure internet communication possible.

In non-technical terms, it boils down to hiding the communications plain sight, behind a riddle.  A 3rd party observer listening to the conversation has access to enough information to solve the riddle.  However the riddle is so massive and complex that it could not be solved within any reasonable amount of time, even with the help of all the computing power on earth.

Let's go thru a step-by-step look at a super-basic implementation of a public key encryption process.

We start with Alice, who wants to securely view information from her bank's website.  Alice's web browser and the bank's server engage in a 'handshake' where they agree on a public key for encryption.  Let's call it `x`.  This value is available to any eavesdroppers who are listening to the network traffic, so they will also know the public key.

{% highlight bash %}

            eavesdropper
                 | x = 4
                 |
                 |
                 |
Alice ----------------------- Bank

{% endhighlight %}

--

Next, Alice and the Bank each select a private key, which they do not share publicly.  Let's call Alice's `a`, and the Bank's `b`.

{% highlight bash %}

            eavesdropper
                 | x = 4
                 |
                 |
                 |
Alice ----------------------- Bank
a = 6                         b = 8
{% endhighlight %}

--

Now Alice and the Bank both multiply the public key by their private key, creating `ax` and `bx`, and exchange their results over the public network.

{% highlight bash %}

            eavesdropper
                 | x = 4
                 | ax = 24
                 | bx = 32
                 |
Alice ----------------------- Bank
a = 6                         b = 8
{% endhighlight %}

--


Now the trick:
* Alice multiplies her private key `a` by the number the Bank sent her, `bx` (`6 * 32` = 192)
* the Bank multiplies their private key `b` by the number Alice sent them, `ax` (`8 * 24` = 192)

Both parties arrive at `abx = 192` which is their private key.  This key can be used to decrypt communication between Alice and the Bank.


{% highlight bash %}

            eavesdropper
                 | x = 4
                 | ax = 24
                 | bx = 32
                 |
Alice ----------------------- Bank
a = 6                         b = 8
              abx = 192

{% endhighlight %}

As you have probably thought, it would be very easy for the eavesdropper to do some simple division using the the public numbers, and "crack" the private keys.

`ax / x = a` and `bx / x = b`

Of course this is true.  However, imagine we made a few changes to increase our level of complexity.

* use much larger starting numbers
* instead of transmitting the entire `bx` and `ax` values over the wire, what if Alice and the Bank truncated the results and only sent the least significant digits.  For example, if the value of `ax` were 16 digits long, Alice would only send the final 8 digits, and Bank would do the same.  This way, the eavesdropper's job of simple division with known values becomes a hugely complex and expensive task of trial division with unknown values.
* instead of using basic multiplication, what if we used exponents instead.  Again, leading to larger numbers and higher complexity for brute force hackers


--

There is SO much more that happens with modern public key encryption, but I am enjoying learning the basics.  

*Props to [YouTube user Thomas Spandöck for the video which I adapted to this post](https://www.youtube.com/watch?v=yUeYMCIQY8I)*
