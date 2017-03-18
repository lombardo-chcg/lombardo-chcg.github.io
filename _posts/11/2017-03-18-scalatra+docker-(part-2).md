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

# Part 2: Add JSON support

[In part one]() we kickstarted a basic Scalatra web services app.  Now we will add JSON support so it can act like a standard web API.

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

*note: if you want to see the entire file in its finished state [check out this commit](https://github.com/lombardo-chcg/scalatra-docker/blob/1df7a664de6d25513a1c2c56569be19ebbfa94f7/src/main/scala/com/lombardo/app/DemoApiServlet.scala)*

In the terminal, let's restart our server so we can test it out.

{% highlight bash %}
sbt
> jetty:start
{% endhighlight %}

Once we see `Server:main: Started` let's check out our new API.  Using Postman or curl hit `http://localhost:8080`.  JSON FTW!
