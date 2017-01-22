---
layout: post
title:  "jq and bash, part II"
date:   2017-01-21 22:13:32
categories: tools
excerpt: "continuation of lil fun with jq, this time using output from jq in a bash read/while loop"
tags:
  - bash
  - jq
  - JSON
---

[Yesterday](https://lombardo-chcg.github.io/tools/2017/01/20/lil-fun-with-jq.html) we saw how to read key/value pairs from a JSON document and map them into a bash friendly format.  Today we finish the job with a read/while loop.

A read/while loop is a simple bash construct that loops over input and maintains the integrity of each line.  This is perfect for dealing with JSON key/value pairs.

As a reminder, here's the output of our jq command:
{% highlight bash %}
jq -r ".widget.text|to_entries|map(\"\(.key)=\(.value)\")|.[]" < "example.json"

#=> data=Click Here
#=> size=36
#=> style=bold
{% endhighlight %}

The key is to pipe the jq output into a while loop, which is done by enclosing the jq command in a `< <(  )` syntax.  Check out the basic implementation:

{% highlight bash %}
while read line; do
  echo $line
done < <(jq -r ".widget.text|to_entries|map(\"\(.key)=\(.value)\")|.[]" < "example.json")

#=> data=Click Here
#=> size=36
#=> style=bold
{% endhighlight %}

Great.  We're almost there.  Now we just need to extract the key / value pairs.  This is done by specifying the *internal field separator* or IFS, which is an internal bash variable that denotes the char which separates words.  It defaults to a white space, but we can use any char we want.  In this case we will use the `=` sign.

{% highlight bash %}
while IFS="=" read key value; do
  echo "key is '$key'"
  echo -e "value is '$value'\n"
done < <(jq -r ".widget.text|to_entries|map(\"\(.key)=\(.value)\")|.[]" < "example.json")

#=> key is 'data'
#=> value is 'Click Here'

#=> key is 'size'
#=> value is '36'

#=> key is 'style'
#=> value is 'bold'
{% endhighlight %}

This is awesome.  We now have access to the JSON data as easily as if we were in a JavaScipt application.  Now we can do whatever we need to do with the data.  My recent use case was setting environmental variables:
{% highlight bash %}
while IFS="=" read key value; do
  export $key="$value"

  echo "env var '$key' is set to ${!key}"
done < <(jq -r ".widget.text|to_entries|map(\"\(.key)=\(.value)\")|.[]" < "example.json")

#=> env var 'data' is set to Click Here
#=> env var 'size' is set to 36
#=> env var 'style' is set to bold
{% endhighlight %}

Good stuff.  With jq and a read while loop it becomes possible to make very robust bash scripts to accomplish many useful tasks.

*Note: For a post about how I'm accessing the value of the env variable in that last example(`${!key}`), see [this post](https://lombardo-chcg.github.io/tools/2017/01/16/vars-within-vars.html)*
