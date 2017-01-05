---
layout: post
title:  "read the man"
date:   2017-01-03 12:54:45
categories: tools
excerpt: "bash's sed command, and the value of reading the manual"
tags:
  - bash
  - documentation
---

I've been working with the bash `sed` command lately to do some appending of text to an existing file at compile time.
The key was to be able to insert text into a configuration file, just after a certain line.

My initial googlings led me to go with the most well-known `sed` syntax for this operation:
{% highlight bash %}
sed 's/existingText/existingText+newText/' tempfile > finalFile
{% endhighlight %}

but that got clunky very quickly.  I was only trying to insert some text.  Why do I have to quote the text, then re-quote it (essentially blowing it away and then reinserting it)?  Seemed inefficient.

I decided to check out the `sed` manual (`man sed`) and I was happy with what I saw.  

Things got even better when I started reading the [GNU manual](https://www.gnu.org/software/sed/manual/sed.html) for `sed` which was a FANTASTIC resource. It was actually way better than the command line manual that comes with Mac OS.  More on that difference in a moment.  

Turns out there is a `a\` command that can be passed to `sed` that accepts an address (line number) and then appends text at that point.  This is a much better and cleaner solution to my problem.

Syntax looks like this:
{% highlight bash %}
$ seq 3 | sed '2a\
hello'
{% endhighlight %}

or in my example using a file and variables instead of piping in input:
{% highlight bash %}
mv finalFile > tempFile

sed "15a\\
  $textStoredAsBashVar\\
  $moreTextFromVar\\
" tempFile > finalFile

rm tempFile
{% endhighlight %}

You'll notice that I'm not using the `sed -i` flag to do the replacement inline, opting instead for creating a temp file, operating on the temp file, then writing the result back as the final file.  The reason for this is that there seems to be some differences between the `sed` on Linux which is where my code will be run, and `sed` on Mac OS X (based on BSD) which is where I am writing the code, and this includes the `-i` flag.

### TL;DR
The best answers aren't always the first Stack Overflow results on Google.  Sometimes you just gotta READ THE F***ING MANUAL.

The version of bash running in Linux and OS X have subtle differences. `sed` is one place where we may encounter these differences.  It is important to be mindful as we write code on a mac that will be deployed in a Linux env.
