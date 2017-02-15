---
layout: post
title:  "totally DRY...but at what cost?"
date:   2017-02-14 21:24:32
categories: wisdom
excerpt: "sometimes it's ok to repeat yourself"
tags:
  - refactoring
---

One of the first things taught in online software developer tutorials is the DRY principle, as in Don't Repeat Yourself.  The fundamental idea is solid: don't repeat processes, don't repeat logic.  Most of all don't copy and paste code.  Less lines are easier to maintain.

This is a great idea and I subscribe.  However, taking it to the extreme can actually have a detrimental impact on readability and therefore on maintainability.  As my career progresses I am starting to see the wisdom in choosing readability over cleverness and pure DRYness.  I would much rather have to debug some software that is easier to read and reason about vs. overly abstracted code.  [I have mentioned this theme before]({{ full_base_url }}/wisdom/2017/01/22/the-concrete-and-the-abstract.html) but I really have been experiencing the impact lately and I want to stress it again.
