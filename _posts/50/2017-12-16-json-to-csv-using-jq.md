---
layout: post
title:  "json to csv using jq"
date:   2017-12-16 13:39:38
categories: tools
excerpt: "doing a common conversion from the terminal"
tags:
  - bash
  - JSON
  - csv
  - jq
  - unix
---


The [`jq`]() library features a `@csv` operator for which I recently found a use case.  Here's an example of how to use it:

Input json is an array in a file called `myFile.json`:
{% highlight json %}
[
  {
      "id": 2,
      "name": "An ice sculpture",
      "price": 12.50
  },
  {
      "id": 3,
      "name": "A blue mouse",
      "price": 25.50
  }
]
{% endhighlight %}

Here's out to turn it into csv:

{% highlight bash %}
cat myFile.json | jq -r '.[] | [.id, .name, .price] | @csv' | tr -d '"'

# 2,An ice sculpture,12.5
# 3,A blue mouse,25.5
{% endhighlight %}


The use of `tr` is a bit of a hack.  The `-r` flag on `jq` produces "raw" output, aka not formatted as JSON.  However, the inner JSON strings retain their quotes.  But its easy enough to remove with `tr`

It's also easy to grab the keys for use as headers if required
{% highlight bash %}
cat myFile.json | jq -r '.[0] | keys | @csv' | tr -d '"'

# id,name,price
{% endhighlight %}

Then just pipe each command into a file for clean csv
{% highlight bash %}
cat myFile.json | jq -r '.[0] | keys | @csv' | tr -d '"' >> output.csv
cat myFile.json | jq -r '.[] | [.id, .name, .price] | @csv' | tr -d '"' >> output.csv

cat output.csv
# id,name,price
# 2,An ice sculpture,12.5
# 3,A blue mouse,25.5
{% endhighlight %}
