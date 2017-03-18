---
layout: post
title:  "scalatra+docker (part 2)"
date:   2017-03-18 16:34:39
categories: web-dev
excerpt: "adding JSON support to our Scalatra server"
tags:
  - scalatra
  - scala
  - docker
---

[Here's a github repo which will track this project](https://github.com/lombardo-chcg/scalatra-docker)

--

# Part 2: Add JSON support

[In Part 1]({{ full_base_url }}/web-dev/2017/03/16/scalatra+docker-(part-1).html) we kickstarted a basic Scalatra web services app.  Now we will add JSON support so it can act like a standard web API.

Our first move will be adding the necessary dependencies to our app.  Scala doesn't have JSON support as a native feature so we will need to add [`json4s-jackson`](https://github.com/json4s/json4s) to handle JSON serialization, and [`scalatra-json`](https://mvnrepository.com/artifact/org.scalatra/scalatra-json/2.2.0) which is the Scalatra plugin for handling JSON requests and responses.

Open the `demo-api` project in [IntelliJ](https://www.jetbrains.com/idea/) and accept all the default settings from IntelliJ.  (if you have never used Intellij or have never opened a Scala project in Intellij [check out this link first](https://www.jetbrains.com/help/idea/2016.3/creating-and-running-your-scala-application.html))

In the project root crack open `build.sbt` and look for the block called `libraryDependencies`.  Add these two lines:

{% highlight scala %}
// put a comma after the preceeding line!  ,
"org.scalatra" %% "scalatra-json" % ScalatraVersion,
"org.json4s"   %% "json4s-jackson" % "3.5.0"
{% endhighlight %}

IntelliJ should prompt you to refresh your dependencies.  Go ahead and accept. (alternatively, running the `sbt` and `jetty:start` commands in the terminal will refresh project dependencies)

Now open the main Servlet file.  Mine is at this path:  `src/main/scala/com/lombardo/app/DemoApiServlet.scala`

Let's add the tools for our JSON response.

First we need to import the libraries we just added as dependencies.  In the import section at the top of the file add these two lines:

{% highlight scala %}
import org.json4s.{DefaultFormats, Formats}
import org.scalatra.json._
{% endhighlight %}

Now for some Scala magic...we need to be able to convert our HTTP responses to JSON.  We won't cover Scala implicits here but I will get to that in another post.

Just under the class definition add this line:
{% highlight scala %}
protected implicit val jsonFormats: Formats = DefaultFormats
{% endhighlight %}

Now we need to add the filter which sets our HTTP `Content-Type` header to JSON for every request:

{% highlight scala %}
before() {
  contentType = formats("json")
}
{% endhighlight %}

To make this work we need to add `JacksonJsonSupport` to our class definition:

{% highlight scala %}
class MyScalatraServlet extends CmonIntellijStack with JacksonJsonSupport {
{% endhighlight %}

Alright.  Now we are ready to send some JSON!  We're going to use the Scala Tuple type to create our JSON.

A Tuple in Scala is basically a list, but each item in the list can be of a different type.  This is perfect for JSON where we need to send Strings, Ints, Arrays, and nested Objects.

Remove all the HTML from the `get("/")` block and let's add a Tuple with our greeting:

{% highlight scala %}
get("/") {
  ("message" -> "hello world")
}
{% endhighlight %}

In the terminal, let's restart our server so we can test it out.

{% highlight bash %}
sbt
> jetty:start
{% endhighlight %}

Once we see `Server:main: Started` let's check out our new API.  Using Postman or curl hit `http://localhost:8080`.  JSON FTW!

*note: if you want to see the entire file in its finished state [check out this commit](https://github.com/lombardo-chcg/scalatra-docker/blob/ecb53fc93adc99acfb060eca23736c51cd061762/src/main/scala/com/lombardo/app/DemoApiServlet.scala)*

--

As you can see we are now able to use standard Scala types in our code, but still return standard JSON from our endpoints.  

Let's simulate a data model and RESTful endpoint, as if we were pulling our greetings from a database.

Under the class definition let's make a case class, which is a Scala type for making succinct, immutable objects:

{% highlight scala %}
case class Greeting(language: String, content: String)
{% endhighlight %}

Now lets update our greetings endpoint:
{% highlight scala %}
get("/greetings") {
  val greetings = List(
    Greeting("English", "Hello World"),
    Greeting("Spanish", "Hola Mundo"),
    Greeting("French", "Bonjour le monde"),
    Greeting("Italian", "Ciao mondo")
  )

  greetings
}
{% endhighlight %}

Now from the terminal using `jq` for formatting:
{% highlight bash %}
curl -s http://localhost:8080/greetings | jq
# [
#   {
#     "language": "English",
#     "content": "Hello World"
#   },
#   {
#     "language": "Spanish",
#     "content": "Hola Mundo"
#   },
#   {
#     "language": "French",
#     "content": "Bonjour le monde"
#   },
#   {
#     "language": "Italian",
#     "content": "Ciao mondo"
#   }
# ]
{% endhighlight %}

*again if you want to see the entire file in its finished state [check out this commit](https://github.com/lombardo-chcg/scalatra-docker/blob/ecb53fc93adc99acfb060eca23736c51cd061762/src/main/scala/com/lombardo/app/DemoApiServlet.scala)*
