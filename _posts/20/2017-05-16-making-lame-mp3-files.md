---
layout: post
title:  "making lame mp3s"
date:   2017-05-16 22:53:43
categories: tools
excerpt: "using LAME to compress audio files"
tags:
  - mp3
  - wav
  - compression
  - bash
  - terminal
---

The more time I spend programming the more I realize how much efficiency can be gained by using the command line for as much as possible.

This holds true for audio conversion.  One of my hobbies is making digital recordings of music and mixes from my record collection.  I record `.wav` files but I want to compress them to `.mp3` so I can listen on my portable devices.  It's a cinch with LAME, which stands for `Lame ain't an MP3 encoder`.  It comes standard on OSX.

A simple command to make a 192bitrate mp3 file:

{% highlight bash %}
lame -b 192 inputFile.wav outputFile.mp3
{% endhighlight %}


`man lame` of course gets you a list of all the available options (and they are many)

It makes quick work of the conversion.  I'm sold.
