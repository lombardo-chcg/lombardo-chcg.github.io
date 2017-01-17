---
layout: post
title:  "vars within vars"
date:   2017-01-16 21:17:11
categories: tools
excerpt: "indirect variable expansion in bash"
tags:
  - bash
---

Problem: I need to access the value of an environmental variable at runtime, but the variable's name is being passed in dynamically at runtime (for example, in a loop).  How do I echo a variable within another variable reference?


Example:
{% highlight bash %}
export SAMPLE_ENV_VARIABLE="http://www.myEndpoint.com"

function doStuffWithEnvVar() {
  envVarName=$1  # $1 refers to the first argument passed to the function

  echo $envVarName
}

doStuffWithEnvVar SAMPLE_ENV_VARIABLE
#=> SAMPLE_ENV_VARIABLE
{% endhighlight %}

Crap!  It's echoing out the literal string argument that was passed in.  I need to access the *value* that the argument is referencing (aka the http address).  The 'var within the var' is what I need.

Some unique bash syntax to the rescue.  Instead of `echo $envVarName`, we do `echo ${!envVarName}`.  It's totally different than my normal understanding of a `!` (bang) operator, which is usually a 'not' operator (i.e. if NOT this, do that).  

In this case, the bang operator allows us to access the value indirectly.  The bash manual refers to this as 'indirect expansion'.

Updated function:
{% highlight bash %}
export SAMPLE_ENV_VARIABLE="http://www.myEndpoint.com"

function doStuffWithEnvVar() {
  envVarName=$1  # $1 refers to the first argument passed to the function

  echo ${!envVarName}
}

doStuffWithEnvVar SAMPLE_ENV_VARIABLE
#=> http://www.myEndpoint.com
{% endhighlight %}

And that's how we get the value we need.
