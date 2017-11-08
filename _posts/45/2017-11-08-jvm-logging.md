---
layout: post
title:  "jvm logging"
date:   2017-11-08 17:42:21
categories: tools
excerpt: "using a bridge between SLFJ4 and log4j2"
tags:
  - scala
  - java
  - jvm
  - log
---

I've run into this message several times while working on Scala applications:

{% highlight bash %}
SLF4J: Failed to load class "org.slf4j.impl.StaticLoggerBinder".
SLF4J: Defaulting to no-operation (NOP) logger implementation
SLF4J: See http://www.slf4j.org/codes.html#StaticLoggerBinder for further details.
{% endhighlight %}

Following the link in the message is helpful of course.  The main takeaways for me from that link are:

> This happens when no appropriate SLF4J binding could be found on the class path.

> When a library declares a compile-time dependency on a SLF4J binding, it imposes that binding on the end-user, thus negating SLF4J's purpose.

From my understanding, what is going on here is that a library I am bringing in has a compile-time dependency on SLFJ4, and since I am using log4j2 in my project, and not bringing in the SLFJ4 logging module directly, I am hosed.  Any logging from my dependencies that use SLF4J will be a No-Op and not displayed.  Leading to a bug hunting nightmare.

The way to fix this is to bring in a "bridge" that routes SLF4J log messages to the Log4J implementation.  The documentation is on the [log4j site](https://logging.apache.org/log4j/2.x/maven-artifacts.html) under "SLF4J Bridge".

> If existing components use SLF4J and you want to have this logging routed to Log4j 2, then add the following but do not remove any SLF4J dependencies.

Here's a segment of a `build.gradle` file which shows this fix in action:

{% highlight groovy %}
def log4jVersion = "2.9.1"
dependencies {
    compile "org.apache.logging.log4j:log4j-api:$log4jVersion"
    runtime "org.apache.logging.log4j:log4j-core:$log4jVersion"
    // this one is the magic:
    runtime "org.apache.logging.log4j:log4j-slf4j-impl:$log4jVersion"
}
{% endhighlight %}

Now the SLF4J logs should appear.


--

[It's better than bad, its good](https://youtu.be/-fQGPZTECYs)
