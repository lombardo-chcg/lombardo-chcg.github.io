---
layout: post
title:  "sbt basics"
date:   2017-07-29 07:45:22
categories: tools
excerpt: "creating basic scaffolding for a Scala project built with sbt and docker"
tags:
  - docker
---

I've been building Scala projects for a while now, but I've either been writing basic, single file scripts or relying on boiler plate such as that which is provided by the Scalatra project.  So I don't really know much about building a Scala project or using the build tooling, sbt.

Today I started work on a mini-app that won't be based on processing http requests.  aka, no Scalatra.  But I quickly realized I don't know how to build such a project.  So let's figure it out.

The goal: build an sbt project that can compile code into a jar, which can then be run in a Docker container.

I've gained much Scala knowledge from Alvin Alexander and I turned again to him here.  I based this post on two of his, but with some special modifications for a different version of scala along with my own end goal of running in docker:
* [How to create an SBT project directory structure](https://alvinalexander.com/scala/how-to-create-sbt-project-directory-structure-scala)
* [How to compile, run, and package a Scala project with SBT](https://alvinalexander.com/scala/sbt-how-to-compile-run-package-scala-project)

First, create and `cd` to a new directory and lay out the project structure:

{% highlight bash %}
mkdir -p src/{main,test}/{java,resources,scala}
mkdir lib project target
{% endhighlight %}

Then create the sbt build definition file:

{% highlight bash %}
touch build.sbt
{% endhighlight %}

Inside `build.sbt`:

{% highlight scala %}
name := "sbt-starter"

version := "0.0.1"

scalaVersion := "2.12.1"
{% endhighlight %}

Now we need to create our app entrypoint.  Since we are in the land of the jvm, this means we need a class with a `main()` method.  [Here's a good intro](https://www.cs.princeton.edu/courses/archive/spr96/cs333/java/tutorial/java/anatomy/main.html) to the `main() method`

{% highlight bash %}
touch src/main/scala/Main.scala
{% endhighlight %}

inside `Main.scala`

{% highlight scala %}
package com.lombardo.app

object Main {
  def main(args: Array[String]) {
    println("Hello from sbt starter pack!")
  }
}
{% endhighlight %}

That's really it.  Now we can run the program:

{% highlight bash %}
sbt run
...
Hello from sbt starter pack!
[success]
{% endhighlight %}

sbt also makes it easy to create a jar for distribution and deployment.  We can then run the resulting jar using the scala compiler:

{% highlight bash %}
sbt package

# [info] Packaging target/scala-2.12/sbt-starter_2.12-0.0.1.jar ...

scala target/scala-2.12/sbt-starter_2.12-0.0.1.jar
# Hello from sbt starter pack!
{% endhighlight %}

Sweet.  Now let's Dockerize it to complete the starter pack.

{% highlight bash %}
touch Dockerfile
{% endhighlight %}

inside `Dockerfile` let's copy over our jar and provide the run command:

{% highlight bash %}
FROM openjdk:8

ADD target/scala-2.12/sbt-starter_2.12-0.0.1.jar /usr/local/bin/target/scala-2.12/sbt-starter_2.12-0.0.1.jar

CMD ["java", "-jar", "/usr/local/bin/target/scala-2.12/sbt-starter_2.12-0.0.1.jar"]
{% endhighlight %}

{% highlight bash %}
docker build -t sbt-starter .
docker run sbt-starter:latest
{% endhighlight %}

what the....

{% highlight bash %}
# Exception in thread "main" java.lang.NoClassDefFoundError: scala/Predef$
# 	at com.lombardo.app.Main$.main(Main.scala:5)
# 	at com.lombardo.app.Main.main(Main.scala)
# Caused by: java.lang.ClassNotFoundException: scala.Predef$
{% endhighlight %}

What, wtf is that?  I thought we added our main method to the class?

We did...but the problem is we did not set an explicit main class in our build definition.  While the scala compiler can detect how to start the app, the java runtime is unable to.  

No problem.  There's an sbt plugin we can use to specify our main class: sbt assembly

{% highlight bash %}
echo 'addSbtPlugin("com.eed3si9n" % "sbt-assembly" % "0.14.4")' >> project/assembly.sbt
{% endhighlight %}

update `build.sbt` to the following:
{% highlight scala %}
name := "sbt-starter"

version := "0.0.1"

mainClass in assembly := Some("com.lombardo.app.Main")

scalaVersion := "2.12.1"
{% endhighlight %}

*side note: the `:=` operator in a sbt build file is apparently to type the value as a string*

Now we are really ready to roll.


{% highlight bash %}
sbt assembly

# [info] Packaging target/scala-2.12/sbt-starter-assembly-0.0.1.jar ...
{% endhighlight %}

Now we just need to update our Dockerfile with the new assembly jar:
{% highlight bash %}
sed -i 's/sbt-starter_2.12-0.0.1.jar/sbt-starter-assembly-0.0.1.jar/g' Dockerfile

docker build -t sbt-starter .

docker run sbt-starter:latest

# Hello from sbt starter pack!
{% endhighlight %}

Success!  I'm looking forward to using this in a upcoming side project.  

[Grab the repo here: https://github.com/lombardo-chcg/sbt-project-starter](https://github.com/lombardo-chcg/sbt-project-starter)
