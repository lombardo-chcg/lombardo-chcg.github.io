---
layout: post
title:  "wikipedia:getting to philosophy"
date:   2017-02-05 22:03:34
categories: code-challenge
excerpt: "solving the wikipedia:getting to philosophy in pure bash"
tags:
  - bash
---

Today's post is a code challenge.

Because I like self-inflicted pain, I decided to solve the *Wikipedia:Getting to Philosophy* challenge in pure bash with no outside libraries.

The biggest hurdle was figuring our how to parse HTML using bash and it became a workout in `sed` and `grep`.

I considered using some type of parsing technology like xpath but in the end I wanted to challenge myself and my bash skills.

Read all about it and check out the source code on my github:
[wikipedia:getting to philosophy](https://github.com/lombardo-chcg/getting_to_philosophy)

example usage:
{% highlight bash %}
./getting_to_philosophy.sh "https://en.wikipedia.org/wiki/House_Music"
{% endhighlight %}


![getting to philosophy sample output1]({{ full_base_url }}/media/getting_to_phil1.png)
![getting to philosophy sample output2]({{ full_base_url }}/media/getting_to_phil2.png)
![getting to philosophy sample output3]({{ full_base_url }}/media/getting_to_phil3.png)
