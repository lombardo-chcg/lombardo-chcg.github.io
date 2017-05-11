---
layout: post
title:  "more on bash env vars"
date:   2017-05-11 06:50:02
categories: tools
excerpt: "making sure environmental variables are available at run time"
tags:
  - bash
  - scripting
---

Say you had a application that depended on certain environmental variables to be available before it ran. 

To export all the variables to the environement in one shot, you can group them in a script file and then `source` that file.  For example:

{% highlight bash %}
touch set_env_vars.sh
{% endhighlight %}

(no `chmod` needed for this example since we won't be executing the script) 

in `env_vars.sh`:
{% highlight bash %}
#!/bin/bash

export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=postgres
export POSTGRES_DB=my_cool_db
{% endhighlight %}


back at the terminal
{% highlight bash %}
source env_vars.sh

# alternative syntax:
# . env_vars.sh

env | grep -i postgres
{% endhighlight %}

you should see a list of those variables, now availabe to subprocesses of the current shell. 