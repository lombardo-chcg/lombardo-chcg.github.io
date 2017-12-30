---
layout: post
title:  "using akka http with json4s part 2"
date:   2017-12-30 10:15:18
categories: tools
excerpt: "deserializing json with akka http and json4s"
tags:
  - scala
  - akka
  - actor
  - json4s
---

In the [last post](/tools/2017/12/29/using-akka-http-with-json4s.html) I set up all the basic config to process Json using `json4s` in the context of Akka HTTP.

In this example I'll show how to "Unmarshal" or deserialize Json from wire format to an instance of a Scala case class.  [*More about how Akka HTTP handles JSON via marshalling and unmarshalling*](https://doc.akka.io/docs/akka-http/current/common/json-support.html)

Let's start by defining a case class that represents the JSON contract for an endpoint:

{% highlight scala %}
final case class JsonRequestBody(userName: String, content: String)
{% endhighlight %}

Since we set up a custom trait for Json support we have the ability to deserialize or "unmarshall" Json that comes thru in a request body.

I'm new to Akka and I am just getting used to its DSL.  But I like it so far.  For example in this request, the `post` directive extracts the request method, then passes the request to its inner route handler if it is valid.  If not, it rejects the request.  The the inner directive, `entity`, receives the request and 'Unmarshalls the requests entity to the given type and passes it to its inner Route'. The whole thing adds a functional feel to HTTP which I dig.

Here's an example with annotations:

{% highlight scala %}
// match on the post request
val postHome = post {
  // Unmarshalls the requests entity and yields to inner block
  entity(as[JsonRequestBody]) { jsonReq => {
    val userName = jsonReq.userName
    val content = jsonReq.content
    complete(
      // here's an example of how to respond with a combination of json fields
      // using json4s Extraction
      Extraction.decompose(
        Map(
          "message" -> s"Welcome, $userName, you said '$content'",
          "sessionId" -> scala.util.Random.nextInt(100000),
          "customObject" -> JsonRequestBody("bob", "helloWorld"),
          "float" -> scala.util.Random.nextFloat,
          "listOfInts" -> List(2, 3, 5, 7, 11),
          "nestedObject" -> Map(
            "nested" -> true,
            "nestedList" -> List(13, 17, 19, 23)
          )
        )
      )
    )
  }}
}
{% endhighlight %}

Accessing the endpoint with a `POST` and a Json blob that matches the `JsonRequestBody` case class I mentioned at the top of the post.

{% highlight bash %}
curl -X POST \
  http://localhost:8080/home \
  -H 'content-type: application/json' \
  -d '{
	"userName": "bob",
	"content": "testing"
}' | jq

# expected JSON is here!
{% endhighlight %}

Excellent!

Akka HTTP will also reply with a helpful error if the request body does not match the expected type:

{% highlight bash %}
The request content was malformed:
No usable value for content
Did not find value which can be converted into java.lang.String
{% endhighlight %}

Here's the full version:

{% highlight scala %}
package com.lombardo.server

import akka.actor.ActorSystem
import akka.http.scaladsl.Http
import akka.http.scaladsl.server.{Directives, PathMatchers, Route}
import akka.stream.ActorMaterializer
import de.heikoseeberger.akkahttpjson4s.Json4sSupport
import org.json4s.Extraction
import org.json4s.JsonDSL._
import org.json4s.jackson.JsonMethods.render

import scala.concurrent.ExecutionContextExecutor
import scala.util.{Failure, Success}

trait JsonSupport extends Json4sSupport {
  implicit val serialization = org.json4s.native.Serialization
  implicit val json4sFormats = org.json4s.DefaultFormats
}

final case class JsonRequestBody(userName: String, content: String)

class WebServer(implicit system: ActorSystem, materializer: ActorMaterializer,
                executionContext: ExecutionContextExecutor)
  extends Directives with JsonSupport {

  val getHome = get {
    complete(render("message" -> "welcome to the fun house"))
  }

  val postHome = post {
    entity(as[JsonRequestBody]) { jsonReq => {
      val userName = jsonReq.userName
      val content = jsonReq.content
      complete(
        Extraction.decompose(
          Map(
            "message" -> s"Welcome, $userName, you said '$content'",
            "sessionId" -> scala.util.Random.nextInt(100000),
            "customObject" -> JsonRequestBody("bob", "helloWorld"),
            "float" -> scala.util.Random.nextFloat,
            "listOfInts" -> List(2, 3, 5, 7, 11),
            "nestedObject" -> Map(
              "nested" -> true,
              "nestedList" -> List(13, 17, 19, 23)
            )
          )
        )
      )
    }}
  }

  val restfulRoutes: Route = path("home") {
    getHome ~ postHome
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
