---
layout: post
title:  "the concrete and the abstract"
date:   2017-01-22 19:11:11
categories: wisdom
excerpt: "finding a middle ground between spaghetti code and extreme abstractions"
tags:
  - refactoring
  - abstractions
---

There is something very satisfying about refactoring spaghetti code into clean, modular code with clear interfaces and dependencies.

However, it is also very easy to take this approach too far.  So far that what was once unreadable spaghetti code is now evasive, unmaintainable modular code.  Abstractions to the extreme.

Another temptation (especially in a modular system like JavaScript's Webpack environment or a inheritance-based paradigm like Java/Spring) is to start the abstractions at the first possible opportunity, instead of waiting concrete, functioning code.  Once this initial working code is in place, the better refactoring opportunities emerge naturally.

As I gain more experience, I am starting to see that premature optimization is the ultimate programming temptation.

I am guilty of this, for sure.  Nothing like a clean modular piece of code.  But, balance is the key.  Must strive to find the middle ground between clean abstractions and functional, maintainable code.

Some wisdom from [@fronx](https://twitter.com/fronx?lang=en) that crystallizes this thought pattern:

![fronxTweet]({{ full_base_url }}/media/fronx_tweet_1.jpg)
-
![fronxTweet]({{ full_base_url }}/media/fronx_tweet_2.jpg)
