---
layout: post
title:  "scalatra+docker (part 4)"
date:   2017-03-25 13:04:14
categories: web-dev
excerpt: "creating a docker image from our scalatra jar"
tags:
  - scala
  - scalatra
  - docker
---

[Here's a github repo which will track this project](https://github.com/lombardo-chcg/scalatra-docker)

--

[Last time](/web-dev/2017/03/19/scalatra+docker-(part-3).html) we saw how to turn a standard Scalatra server into a fat JAR which could be run with a single command.  Today we're going to build a Docker image so we can take advantage of containerizing our application.

The process of creating a Docker image is very straightforward.  Here's the basic steps we are going to take:

* First, start from a base image which contains an OS and a Java Development Kit (JDK).  The JDK provides the necessary tools to run a Java application.
* Second, add our fat JAR to this base image
* Third, provide the command statement and configuration needed to run our application.

And that's it. Let's get started by creating a `Dockerfile` in the root of our application.

{% highlight bash %}
touch Dockerfile
{% endhighlight %}

Next we need to find a base Docker image which can support our app.  [I chose to use the official Docker JDK image](https://hub.docker.com/_/openjdk/), version 8.  As a reminder, this image provides us with a Linux OS and a fully installed Java Development environment.  Perhaps in a future post I will investigate building a base image from scratch.  But for now, let's use this JDK image.

We will be using standard commands from the [Dockerfile DSL](https://docs.docker.com/engine/reference/builder/#from).  The `FROM` command is the first command and provides the base image.
{% highlight bash %}
FROM openjdk:8
{% endhighlight %}

Next, we need to layer our JAR on top of the base image.  We use the `ADD` instruction to tell Docker to add our JAR from its local path to a specific path inside the image.  We will place the JAR in  `/usr/local/bin/`
{% highlight bash %}
FROM openjdk:8
ADD ./target/scala-2.12/demo-api-assembly-0.1.0-SNAPSHOT.jar /usr/local/bin/demo-api-assembly-0.1.0-SNAPSHOT.jar
{% endhighlight %}

--

*note: to find your local JAR, use the bash `find` tool like so:*
{% highlight bash %}
find . -name "*demo-api-assembly*.jar"
{% endhighlight %}
*You want to make sure you grab the assembly JAR which is the fat version we need.*

--

Next we need to tell Docker our start command for this application.  This can be done in several ways.  The start command can be placed directly in the Dockerfile with the `CMD` instruction.  In our case we are going to put the command in a shell script, add the script to the image and then tell Docker to run the script upon initializing the container.

{% highlight bash %}
mkdir scripts
touch scripts/init.sh
{% endhighlight %}

Inside the `init.sh` file we provide the run command a little feedback for the user:

{% highlight bash %}
#!/bin/bash

echo "starting your JAR..."

java -jar /usr/local/bin/demo-api-assembly-0.1.0-SNAPSHOT.jar
{% endhighlight %}

Now we need to layer the script on top of the image and make it executable.  We will place the script in the same directory as the JAR.  Here's our updated Dockerfile:

{% highlight bash %}
FROM openjdk:8

ADD ./target/scala-2.12/demo-api-assembly-0.1.0-SNAPSHOT.jar /usr/local/bin/demo-api-assembly-0.1.0-SNAPSHOT.jar
ADD /scripts/init.sh /usr/local/bin/init.sh

RUN chmod a+x /usr/local/bin/init.sh
{% endhighlight %}

Almost there!  We also need to `EXPOSE` a port in the container, telling Docker which port the container will be listening to.

{% highlight bash %}
FROM openjdk:8

ADD ./target/scala-2.12/demo-api-assembly-0.1.0-SNAPSHOT.jar /usr/local/bin/demo-api-assembly-0.1.0-SNAPSHOT.jar
ADD /scripts/init.sh /usr/local/bin/init.sh

RUN chmod a+x /usr/local/bin/init.sh

EXPOSE 8080
{% endhighlight %}

And finally, we tell Docker the entry point for the application, which is our shell script.

{% highlight bash %}
FROM openjdk:8

ADD ./target/scala-2.12/demo-api-assembly-0.1.0-SNAPSHOT.jar /usr/local/bin/demo-api-assembly-0.1.0-SNAPSHOT.jar
ADD /scripts/init.sh /usr/local/bin/init.sh

RUN chmod a+x /usr/local/bin/init.sh

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/init.sh"]
{% endhighlight %}

Alternatively, we could just put the command in the file like this:

{% highlight bash %}
CMD java -jar /usr/local/bin/demo-api-assembly-0.1.0-SNAPSHOT.jar
{% endhighlight %}

But I prefer to use the shell script since I am a bash head...

Our image is ready to be built.  We use the  `Docker build` command for this purpose.  Making sure you are in the project root, run this:

{% highlight bash %}
docker build -t demo-scalatra-api .
{% endhighlight %}

We are telling Docker to build an image, the `-t` flag simply gives a tag to the image so we can easily find it and start it, and the `.` lets it know the 'context' of the build, or where all the source files are located.

Alright!  Now run that `docker build` command above.  Docker will pull our base image, then layer our code on top as specified in our Dockerfile.

A quick `docker images` command will show our newly created image, ready to be deployed as a container.  Now all we need to do is start it up!

Let's tell Docker to run our image and to bind port 8080 of our local docker host to port 8080 of the container.  You could also pass a `-P` and docker will bind the container to a random port on your localhost.  

{% highlight bash %}
docker run -p 8080:8080 demo-scalatra-api
{% endhighlight %}

See some familiar output?  Now you can hit `http://0.0.0.0:8080/greetings` and see the output from the container.  

Success!  We have containerized our Scalatra app.  Next, we will push our image to Dockerhub to share, and also see how to setup a local network where our front-end Nginx container can be linked to our Scalatra API for data.

To bring down the container:

{% highlight bash %}
docker ps
# CONTAINER ID        IMAGE
# 18533a7bfcbb        demo-scalatra-api

docker stop 18533a7bfcbb
{% endhighlight %}

[*finished state of the code after this post*]()
