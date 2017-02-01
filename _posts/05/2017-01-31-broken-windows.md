---
layout: post
title:  "broken windows"
date:   2017-01-31 21:16:02
categories: wisdom
excerpt: "keeping code clean by enforcing standards on the little things"
tags:
  - code-standards
---

Been doing this 5-times-a-week mini blog thing for a month now.  So far I am loving it!

I picked up a copy of *The Pragmatic Programmer* by Andrew Hunt & David Thomas, based on the recommendation of a Sr. Engineer at my company.  I was expecting a dense read but I have found it to be quite the opposite.  It's a collection of practical, easily digestible chapters that focus on improving the reader's ability to craft quality applications immediately.

One axiom I love from the book is  "Don't Live with Broken Windows" (insert microsoft joke...).  The idea is based on an abandoned car experiment.  For one week, the car was left to sit and nothing happened.  Then when a window was broken, the car was stripped and vandalized within hours.

The takeaway is that once a broken window exists and is noticed by others, chaos and disorder follow.  Here are some examples of broken windows in software that I can think of:

* writing crappy unit tests that provide 'code coverage' but not value
* merging in code that doesn't meet pre-defined standards (i.e. commit message format, linting rules)
* not writing documentation
* pushing code to meet a deadline and not going back to refactor it
* not following design patterns for separation of concerns (i.e. writing fat controllers)
* allowing mutable state to leak throughout the application by being lazy 

These types of behaviors all open the door for more of the same behavior to follow, and pretty soon, everyone is doing it and there is no handle on quality.
