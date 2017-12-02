---
layout: post
title:  "well that escalated quickly"
date:   2017-12-01 16:19:26
categories: code-challenge
excerpt: "quick look at Up-Arrow notation to denote giant numbers"
tags:
  - algorithm
  - euler
---

I highly recommend the [`Numberphile`](https://www.youtube.com/channel/UCoxcjq-8xIDTYp3uz647V5A) YouTube channel for some really cool vids!!

I was recently watching their videos on [Graham's Number](https://en.wikipedia.org/wiki/Graham%27s_number) and found out about this cool thing called [Knuth's up-arrow notation](https://en.wikipedia.org/wiki/Knuth%27s_up-arrow_notation).

`3`&#8593;`3` == `Math.pow(3, 3)` == `27`

`3`&#8593;&#8593;`3` == `3`&#8593;(`3`&#8593;`3`) == `BigInt(3).pow(27)` == `7625597484987`

`3`&#8593;&#8593;&#8593;`3` == `3`&#8593;&#8593;(`3`&#8593;&#8593;`3`) == `Math.pow(3L, 7625597484987L)` == `...`

The Scala compiler says `Math.pow(3L, 7625597484987L)` equals Infinity.  Not quite...`3`&#8593;&#8593;&#8593;`3` has 3.6 trillion digits but is definitely finite.  And its not even close to Grahams number.

But we went from 27 to a number with 3.6 trillion digits in 2 steps.  Like I said...that escalated quickly.  

Watch the whole video for all the goodness:
<iframe width="560" height="315" src="https://www.youtube.com/embed/GuigptwlVHo?rel=0" frameborder="0" allowfullscreen></iframe>
