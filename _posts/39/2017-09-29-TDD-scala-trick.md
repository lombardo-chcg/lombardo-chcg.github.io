---
layout: post
title:  "TDD scala trick"
date:   2017-09-29 22:29:11
categories: "languages"
excerpt: "trick for red to green refactoring in scala"
tags:
  - scala
  - test
---

There exists a `Predef` object in the Scala language:

> The `Predef` object provides definitions that are accessible in all Scala
> compilation units without explicit qualification.

It is composed of many common helpers such as `printf` and `assert`.

There's also this interesting one:

{% highlight scala %}
def ??? : Nothing = throw new NotImplementedError
{% endhighlight %}

The use?

> `???` can be used for marking methods that remain to be implemented.

This is perfect for TDD.  Input and Return types can even be specified, and best of all the code will still compile.

{% highlight scala %}
def deserializeMessage(input: Array[Byte]): String = {
  ???
}

// explicitly: 

def deserializeMessage(input: Array[Byte]): String = {
  scala.Predef.???
}
{% endhighlight %}

This means we can go write some failing unit tests, come back and write the code to make the tests pass.
