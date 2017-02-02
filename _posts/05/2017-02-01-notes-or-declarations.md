---
layout: post
title:  "notes or declarations"
date:   2017-02-01 19:11:57
categories: wisdom
excerpt: "communicating intention to the person reading your application code"
tags:
  - code-standards
---

Had a nice discussion today about bringing clarity to code.

Specifically: when faced with a complex series of operations, does it make more sense to abstract out single-purpose helper functions with declarative names, or does it make more sense to add comments to give the reader insight into what is happening?

For example, here's a nasty looking nonsense conditional:

{% highlight javascript %}
function proceedWithPurchase(cart, user) {
  if ((cart.accessories.length > 0 && cart.accessories.inventory >= cart.total) || user.credit > cart.total)  {
    cart.process()
  }
}
{% endhighlight %}

Let's discuss two ways to fix this code.  First, add comment to explain what is going on:

{% highlight javascript %}
function proceedWithPurchase(cart, user) {
  // if the cart is valid or if the user has valid store credit
  if ((cart.accessories.length > 0 && cart.accessories.inventory >= cart.total) || user.credit > cart.total)  {
    cart.process()
  }
}
{% endhighlight %}

Or, refactor the conditions out to declarative helper functions that return booleans.

{% highlight javascript %}
function proceedWithPurchase(cart, user) {
  if (cartIsValid(cart) || userHasStoreCredit(user))  {
    cart.process()
  }
}

function cartIsValid(cart) {
  return cart.accessories.length > 0 && cart.accessories.inventory >= cart.total;
}

function userHasStoreCredit(user) {
  return user.credit > cart.total && user.credit.valid;
}
{% endhighlight %}

Which way is better?  There's no right answer here.  Easy to argue both sides.

But consider an axiom that someone said during our discussion today:

*Use comments to provide the why, not to explain the what.*

For example, use a comment to explain why a hardcoded value is present in a function (i.e. some business reason), not to explain what is actually happening with logic.

Following this axiom, it makes more sense to break up complex functionality into smaller, composable pieces with declarative names.  These names explain what the function is doing while hiding the logic.  This is a pillar of functional programming which I am gravitating to over time.
