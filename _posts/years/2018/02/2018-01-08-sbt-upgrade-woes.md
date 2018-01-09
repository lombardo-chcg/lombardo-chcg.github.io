---
layout: post
title:  "sbt upgrade woes"
date:   2018-01-08 18:12:53
categories: tools
excerpt: "fixing issues that arose with the upgrade to sbt 1.x"
tags:
  - scala
  - sbt
  - gradle
---

*note: I am running sbt 1.0.4 in this example*

### SBT v.1 upgrade issue #1


If you are running sbt version 1.x and encounter the following error while running any sbt command:

{% highlight bash %}
No Java Development Kit (JDK) installation was detected.
{% endhighlight %}

It may be because your shell profile has custom `GREP_OPTIONS` which are preventing the sbt launcher from properly parsing your JDK version from a `grep` command.

Here's the source code which contains the grep command which was breaking things for me: [github sbt code](https://github.com/sbt/sbt-launcher-package/blob/v1.0.4/src/universal/bin/sbt-launch-lib.bash#L183)

Solution 1: disable `GREP_OPTIONS` in your bash profile.

Solution 2: [use Gradle instead](https://github.com/lombardo-chcg/scala-gradle-starter)

--

### SBT v.1 upgrade issue #2

If you are running sbt version 1.x and encounter the following error while running any sbt job:

{% highlight bash %}
java.lang.OutOfMemoryError: Metaspace
{% endhighlight %}

You can increase the jvm memory allotment by passing the following flag while running any sbt command:

{% highlight bash %}
sbt -mem 2018
{% endhighlight %}

If you are using sbt on OSX installed via Homebrew you can also edit the following file to make the setting permanent:

{% highlight bash %}
/usr/local/etc/sbtopts
{% endhighlight %}

Just uncomment the following and add your new setting:

{% highlight bash %}
# set memory options
#
#-mem   <integer>
{% endhighlight %}
