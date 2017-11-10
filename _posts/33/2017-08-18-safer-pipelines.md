---
layout: post
title:  "safer pipelines"
date:   2017-08-18 18:59:11
categories: tools
excerpt: "failing fast in bash script pipelines"
tags:
  - bash
  - unix
  - shell
---

> Crash Early.  A dead program normally does a lot less damage than a crippled one.
>
> [-*The Pragmatic Programmer*](https://pragprog.com/the-pragmatic-programmer/extracts/tips)

Wise words from a great book.  Let's see how to do it in a bash script.

This script runs a `curl` command which will fail due to a bad url.  The goal will be to "catch" that failure and exit the script, without processing further instructions, drawing immediate attention to the error and not running other commands pointlessly or dangerously. 

`pipefail.sh` version 1:
{% highlight bash %}
#!/bin/bash

curl "http://1234.4567.fake.url.789.789.789.789.789" | echo "end of pipeline command"
echo "you shouldn't be seeing me cause this script errored out"
{% endhighlight %}

execution:  
{% highlight bash %}
./pipefail.sh

# end of pipeline command
# curl: (6) Could not resolve host: 1234.4567.fake.url.789.789.789.789.789
# you shouldn't be seeing me cause this script errored out

echo $? # => the script's exit code
# 0
{% endhighlight %}

That's not good.  Our script "failed" due to the bad curl request.  But we still exited with a `0` status code, which is the code for green.  And the command that followed the error still ran.

Now let's do a traditional error handling technique in bash: `set -e`

From the [man](http://linuxcommand.org/lc3_man_pages/seth.html):
> -e  Exit immediately if a command exits with a non-zero status.

`pipefail.sh` version 2:
{% highlight bash %}
#!/bin/bash

set -e

curl "http://1234.4567.fake.url.789.789.789.789.789" | echo "end of pipeline command"
echo "you shouldn't be seeing me cause this script errored out"
{% endhighlight %}

execution:  
{% highlight bash %}
./pipefail.sh

# end of pipeline command
# curl: (6) Could not resolve host: 1234.4567.fake.url.789.789.789.789.789
# you shouldn't be seeing me cause this script errored out

echo $? # => the script's exit code
# 0
{% endhighlight %}

Not good at all.  What's happening here?

The `curl | echo` pipeline executes an `echo` as its last command, which is successful.  So even though the `curl` command is "throwing" an error, there is no one to "catch" it, and the program continues thru and proceeds to a successful termination.

Now, let's see about the `pipefail` option.  From the man page:

> the return value of a pipeline is the status of the last command to exit with a non-zero status, or zero if no command exited with a non-zero status

`pipefail.sh` version 3:
{% highlight bash %}
#!/bin/bash

set -eo pipefail

curl "http://1234.4567.fake.url.789.789.789.789.789" | echo "end of pipeline command"
echo "you shouldn't be seeing me cause this script errored out"
{% endhighlight %}

execution:  
{% highlight bash %}
./pipefail.sh

# end of pipeline command
# curl: (6) Could not resolve host: 1234.4567.fake.url.789.789.789.789.789

echo $? # => the script's exit code
# 6
{% endhighlight %}

Great.  Now our script is terminating when an inner-pipeline command fails, and exiting with an error code of 6.  This is a good way to Crash Early in a bash script.
