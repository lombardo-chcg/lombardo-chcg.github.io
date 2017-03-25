---
layout: post
title:  "scalatra+docker (part 5)"
date:   2017-03-25 15:24:32
categories: web-dev
excerpt: "publishing our image to docker hub"
tags:
  - docker
  - scalatra
---

[Here's a github repo which will track this project](https://github.com/lombardo-chcg/scalatra-docker)

--

[In our last post](/web-dev/2017/03/25/scalatra+docker-(part-4).html) we successfully built a Docker image and started a container based on that image.  Now, we are going to publish the image to Docker Hub so that we can use it in other projects.

First step is to [sign up for a Docker Hub account](https://hub.docker.com/).

Once you have an account established, we need to [tag our Scalatra app image appropriately](https://docs.docker.com/engine/getstarted/tutimg/tagger.png).

{% highlight bash %}
docker images
# REPOSITORY                          TAG                 IMAGE ID
# demo-scalatra-api                   latest              fd93c4502d7c

docker tag fd93c4502d7c <YOUR_DOCKER_HUB_NAME>/demo-scalatra-api:latest
{% endhighlight %}

Now check `docker images` again to confirm the tag has been applied.

Now just run `docker login` and enter your credentials.

Finally, issue the command to push the image (using your account name of course):

{% highlight bash %}
docker push lombardo/demo-scalatra-api
{% endhighlight %}

Now if you check your account on Docker Hub, you will see a page for the image.

To confirm, run `docker rmi` with the image number to delete it locally.  Then execute the `docker run` command [from the last tutorial](/web-dev/2017/03/25/scalatra+docker-(part-4).html) with the remote image tag.  Your image will be pulled and started!

{% highlight bash %}
docker run -p 8080:8080 lombardo/demo-scalatra-api
{% endhighlight %}
