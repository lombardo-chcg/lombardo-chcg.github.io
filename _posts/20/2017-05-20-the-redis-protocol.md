---
layout: post
title:  "the redis protocol"
date:   2017-05-20 08:57:39
categories: databases
excerpt: "using scala to prepare data for mass insertion into redis"
tags:
  - scala
  - redis
  - file
  - Serialization
---

According to the [Redis docs](https://redis.io/topics/protocol), "Redis clients communicate with the Redis server using a protocol called RESP (REdis Serialization Protocol)"

In a general sense, data serialization is the process of mapping human-readable data structures into collections of bits that can be stored and transmitted by computer systems [reference](https://en.wikipedia.org/wiki/Serialization).

So this process means taking data and converting it into a format for insertion into Redis. My use case here is preparing hundreds of thousands of lines of data in a `txt` file for mass, one-time insertion into Redis.

The Redis docs are some of the best I've seen.  [The provide a detailed walkthru](https://redis.io/topics/mass-insert) of mass insertion procedure including a Ruby example.

Here's a typical Redis cli command to set a Key/Value pair into the database:

{% highlight bash %}
SET illinois springfield
{% endhighlight %}

Here's what it looks like in Redis Protocol:

{% highlight bash %}
*3<cr><lf>
$3<cr><lf>
SET<cr><lf>
$3<cr><lf>
key<cr><lf>
$5<cr><lf>
value<cr><lf>

or

"*3\r\n$3\r\nSET\r\n$8\r\nillinois\r\n$11\r\nspringfield\r\n"
{% endhighlight %}

As you can see it is making use of ASCII characters:
* `\r` aka `<cr>` for carriage return (returning to the beginning of the line)
* `\n` aka `<lf>` for new line (line feed)

So we need to write a function to do this mapping.  As I said there is a Ruby version on the [Redis](https://redis.io/topics/mass-insert) site, but I wanted to try it in Scala (since this is for my [ongoing Scalatra/Docker project](https://lombardo-chcg.github.io/search?term=scalatra)):

{% highlight scala %}
import java.nio.charset.StandardCharsets._

val generateRedisProtocol = (args: List[String]) => {
  val protocol = new StringBuilder().append("*").append(args.length).append("\r\n")

  args.foreach { arg =>
    val length = arg.getBytes(UTF_8).length
    protocol.append("$").append(length).append("\r\n").append(arg).append("\r\n")
  }

  protocol.result
}: String

{% endhighlight %}

{% highlight bash %}

scala> generateRedisProtocol(List("SET", "illinois", "springfield"))

# res0: String =
# "*3
# $3
# SET
# $8
# illinois
# $11
# springfield
# "
{% endhighlight %}

What's nice about using a Scala `List` as the input param is this function can be used to generate other Redis commands that have an indeterminate input length , such as a list (`LPUSH mylist "hello" "world" "this" "is" "my" "list"`)

The multiline result from Scala is doing a literal interpretation on the escaped ASCII characters for newline and carriage return.  Post coming soon about using this output to perform a mass data insertion into Redis.
