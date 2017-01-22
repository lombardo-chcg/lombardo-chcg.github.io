---
layout: post
title:  "lil fun with jq"
date:   2017-01-20 22:52:22
categories: tools
excerpt: "cool features of the json parser utility jq"
tags:
  - jq
  - bash
  - json
---

I have found a need recently to interact with JSON documents in shell scripts.

The jq utility is an open-source command line tool for parsing JSON.  It is loaded with features.

In this example, I am reading from a JSON document and mapping the data to a bash-friendly format so that it can be processed in a script.  Let's go step by step.

[*make sure to install jq if you want to follow along*](https://stedolan.github.io/jq/download/)

contents of example.json file
{% highlight bash %}
{
   "widget":{
      "text":{
         "data":"Click Here",
         "size":36,
         "style":"bold"
      }
   }
}
{% endhighlight %}

At the command line, let's access the object at widget.text:
{% highlight bash %}
jq -r ".widget.text" < "example.json"

#=> {
#=>   "data": "Click Here",
#=>   "size": 36,
#=>   "style": "bold"
#=> }
{% endhighlight %}

nice.  now let's pipe that beautiful JSON into the `to_entries` jq command which gives us convenient access to the keys and values
{% highlight bash %}
$> jq -r ".widget.text|to_entries|.[]" < "example.json"

#=> {
#=>   "key": "data",
#=>   "value": "Click Here"
#=> }
#=> {
#=>   "key": "size",
#=>   "value": 36
#=> }
#=> {
#=>   "key": "style",
#=>   "value": "bold"
#=> }
{% endhighlight %}

Now let's use jq's map functionality to map those keys and values to single line strings, with the key/value pair separated by an `=` sign
{% highlight bash %}
$> jq -r ".widget.text|to_entries|map(\"\(.key)=\(.value)\")|.[]" < "example.json"

#=> data=Click Here
#=> size=36
#=> style=bold
{% endhighlight %}

(gnarly syntax... I know.  it's just for escaping the `"` signs ).

Now this input is perfect for piping into a standard bash command like `read` with the IFS (internal field separator) value set to `=`, which will give us an easy handle to both the keys and values.  I'll go over that in tomorrow's post.
