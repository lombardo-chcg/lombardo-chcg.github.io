---
layout: post
title:  "scala + slack"
date:   2017-06-24 17:33:44
categories: "tools"
excerpt: "quick solution for a slackbot in plain old scala"
tags:
  - scala
  - slack
  - scalatra
---

Here's a quick and dirty Scala class that can be used to send messages to a slack channel.  It uses the [Simplified Http](https://github.com/scalaj/scalaj-http) library and the native scala JSON parsing util.

{% highlight scala %}
package com.lombardo.app.services

import scalaj.http._
import scala.util.parsing.json._

class SlackMessanger {
  val SLACK_INTEGRATION_HOOK = "url for your slack integration hook goes here"
  // create an integration hook via slack's website

  def send(msg: String): HttpResponse[String] = {
    val data = Map(
      "channel" -> "#general",
      "username" -> "scala-slack-bot",
      "text" -> msg,
      "icon_emoji" -> ":ghost:"
    )

    val requestBody = JSONObject(data).toString()

    Http(SLACK_INTEGRATION_HOOK)
      .postData(requestBody)
      .header("content-type", "application/json")
      .asString
  }
}
{% endhighlight %}

Take it further by using a Case Class for the slack message with defaults

{% highlight scala %}
case class SlackMessage(channel: String = "#general",
                        username: String = "my-bot",
                        text: String,
                        icon_emoji: String = ":satellite_antenna:")

// usage:
slackMessanger.send(SlackMessage(text = message))                        
{% endhighlight %}

[Use the previously posted technique](/languages/2017/06/05/intro-to-scala-implicits.html) for turning Case Classes into `Maps` and you can pass the class right to the JSON util:

{% highlight scala %}
def send(msg: SlackMessage): HttpResponse[String] = {
  val requestBody = JSONObject(msg.toMap).toString()

  Http(SLACK_INTEGRATION_HOOK)
    .postData(requestBody)
    .header("content-type", "application/json")
    .asString
}
{% endhighlight %}
