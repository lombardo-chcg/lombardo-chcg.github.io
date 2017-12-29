---
layout: post
title:  "using akka http with json4s"
date:   2017-12-29 12:45:05
categories: tools
excerpt: "setting up a akka http webserver that uses json4s to handle json interactions"
tags:
  - scala
  - akka
  - actor
  - json4s
---

Akka HTTP uses the [spray-json](https://doc.akka.io/docs/akka-http/current/common/json-support.html) library for JSON support.  But this year [I've been spending some time](https://lombardo-chcg.github.io/search?term=json4s) learning the [`json4s` library](http://json4s.org/) so I wanted to leverage that time investment in the context of Akka HTTP.

Here's a quick walkthru of how to use the `json4s` with Akka HTTP.

## Dependencies

I am using Gradle, so here is the relevant code from `build.gradle`

{% highlight groovy %}
def scalaVersion = "2.12.1"
def akkaVersion = "2.5.7"
def json4sVersion = "3.5.0"

dependencies {
    // scala
    compile "org.scala-lang:scala-library:$scalaVersion"
    compile "org.scala-lang:scala-reflect:$scalaVersion"

    // json4s
    compile "org.json4s:json4s-ext_2.12:$json4sVersion"
    compile "org.json4s:json4s-jackson_2.12:$json4sVersion"
    compile "org.json4s:json4s-native_2.12:$json4sVersion"

    // json4s-akka http bridge
    compile "de.heikoseeberger:akka-http-json4s_2.12:1.19.0-M3"

    // akka
    compile "com.typesafe.akka:akka-stream_2.12:$akkaVersion"
    compile "com.typesafe.akka:akka-actor_2.12:$akkaVersion"
    compile "com.typesafe.akka:akka-http_2.12:10.0.11"
}
{% endhighlight %}

To get akka http and json4s to play nicely together, I am going to leverage a open source library I found on Github: [`akka-http-json`](https://github.com/hseeberger/akka-http-json)

The implementation will involve creating a custom `Trait` that extends that `akka-http-json` library and also scopes the necessary `implicit` values.

Here's our sample web server file that handles a `GET` request and responds with JSON:

{% highlight scala %}
package com.lombardo.server

import akka.actor.ActorSystem
import akka.http.scaladsl.Http
import akka.http.scaladsl.server.{Directives, Route}
import akka.stream.ActorMaterializer
import de.heikoseeberger.akkahttpjson4s.Json4sSupport
import org.json4s.JsonDSL._
import org.json4s.jackson.JsonMethods.render

import scala.concurrent.ExecutionContextExecutor
import scala.util.{Failure, Success}

// custom trait for Json support
trait JsonSupport extends Json4sSupport {
  implicit val serialization = org.json4s.native.Serialization
  implicit val json4sFormats = org.json4s.DefaultFormats
}

// the usual config code required for an Akka Http server, mixing in our Json trait too
class WebServer(implicit system: ActorSystem, materializer: ActorMaterializer,
                executionContext: ExecutionContextExecutor)
  extends Directives with JsonSupport {

  // set up a demo route using the #render method of json4s.jackson
  // this allows us to send native Scala code back as Json
  val getHome = get {
    complete(render("message" -> "welcome to the fun house"))
  }

  val restfulRoutes: Route = path("home") {
    getHome
  }

  val bindingFuture = Http().bindAndHandle(restfulRoutes, "0.0.0.0", 8080)

  bindingFuture.onComplete {
    case Success(binding) ⇒
      println(s"Webserver is listening on localhost:8080")
    case Failure(e) ⇒
      println(s"Binding failed with ${e.getMessage}")
      system.terminate()
  }
}
{% endhighlight %}

In `main`class:
{% highlight scala %}
package com.lombardo

import akka.actor.ActorSystem
import akka.stream.ActorMaterializer
import com.lombardo.server.WebServer

import scala.concurrent.ExecutionContextExecutor

object Main {
  def main(args: Array[String]) {
    println("Hello from Akka-Http starter pack!")
    implicit val system = ActorSystem("demo-system")
    implicit val materializer = ActorMaterializer()
    implicit val executionContext:ExecutionContextExecutor = system.dispatcher

    val webServer = new WebServer
  }
}
{% endhighlight %}

{% highlight bash %}

curl localhost:8080/home | jq

# {
#  "message": "welcome to the fun house"
# }
{% endhighlight %}


In the next post we will setup a `POST` endpoint and "unmarshall" some Json.
