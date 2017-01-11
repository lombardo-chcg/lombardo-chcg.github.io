---
layout: post
title:  "stuck in the 70s"
date:   2017-01-09 22:02:48
categories: tools
excerpt: "old school skills, more on sed"
tags:
  - bash
  - sed
---

Today someone told me that I was "stuck in the 70s" due to my ever increasing fascination with bash scripting.  That's a badge of honor to me!  I liken learning bash to learning to dribble and bounce pass in basketball: the basics.  Already it has taught me much about fundamentals such as file i/o, streaming, piping, writing better log/error messages, application design and most importantly paying attention to detail.

Today's knowledge nugget is about using `sed`.  

Problem: I need to do pattern match & replace on a file, but i need to match EXACT standalone words only.  I don't want partial matches (i.e. i want to match "dog" but not "dogsled").

using BSD based `sed` (aka the one that ships with Mac OS X)

replace ALL occurrences of the word `record`:
{% highlight bash %}
echo "record tape cd cdtape recordcd recordrecord record tape cd" | sed 's/record/mp3/g'
#=> mp3 tape cd cdtape mp3cd mp3mp3 mp3 tape cd
{% endhighlight %}

replace only the first occurrence of the word `record` (no `g` flag in the `sed` command)
{% highlight bash %}
echo "record tape cd cdtape recordcd recordrecord record tape cd" | sed 's/record/mp3/'
#=> mp3 tape cd cdtape recordcd recordrecord record tape cd
{% endhighlight %}

replace only the EXACT match of the word `record` using start of word / end of word signifiers:
{% highlight bash %}
echo "record tape cd cdtape recordcd recordrecord record tape cd" | sed 's/[[:<:]]record[[:>:]]/mp3/g'
#=> mp3 tape cd cdtape recordcd recordrecord mp3 tape cd
{% endhighlight %}

note that on GNU sed (found on native Linux machines) uses the start/end word matcher `\< \>`, as in `sed 's/\<record\>/mp3/g'`.   Many sed stackoverflow posts mention the `\< \>` matcher so be careful you Mac users.  Or just install GNU sed!
