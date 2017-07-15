---
layout: post
title:  "hello world, nginx + docker edition (part 4)"
date:   2017-03-30 21:00:03
categories: web-dev
excerpt: "local front end development with nginx and docker"
tags:
  - docker
  - nginx
  - javascript
---

[Here's a github repo which will track this project](https://github.com/lombardo-chcg/nginx-docker)

--

It is good practice to develop like you deploy.  For example, when developing an application that will be deployed as a container, wouldn't it make sense to develop the app in a container as well?   Here are just a few benefits:

* Prevent "deployment surprises" aka finding out the code behaves differently when containerized
* avoid CORS issues by having the containerized server proxy all HTTP requests (instead of making cross origin requests directly from the web browser)
* no need to maintain separate dev and prod build systems.

Probably many more but these sprung to mind.  So we are going to take our previous Nginx + Docker setup and add ability to do local development.

If you're following along, let's remove the "authentication" from the Nginx config file: (just comment it out)

{% highlight lua %}

events { }
http {
    server {
      # auth_basic "Protected Server";
      # auth_basic_user_file /src/passwords;

      location /api/ {
        return 200 '{ "message": "hello world" }';
      }

      location / {
        root /src;
      }
    }
}
{% endhighlight %}

Next, let's create a `docker-compose` file just for development.  The difference is, instead of copying the code from our local system to the Docker image, we will instead mount our local directly as a volume.  This means that when the container runs Docker will pull the files from our local directly as if it were actually inside the container.  [This is done with some straight Docker wizardry](https://docs.docker.com/engine/reference/glossary/#union-file-system) and it is something I want to learn more about in the future.

For now, let's see how to mount our local volume in the container at run time.

First, `touch docker-compose-dev.yml` and make it:

{% highlight yml %}
version: '2'

services:
  hello_world:
    build:
      context: .
      dockerfile: Dockerfile-dev
    volumes:
     - ./src:/src
    ports:
     - "80:80"
{% endhighlight %}

That simple `volumes` instruction gives us the power!

Now we just tell `docker-compose` to use that specific file and we are made.

{% highlight bash %}
docker-compose -f docker-compose-dev.yml up --build
{% endhighlight %}

Visit `http://localhost/` to see the page live.  Now hack some code by changing the title and `h1` content to "Hola Mundo".  Refresh in the browser and bam...you are now developing code from inside a container.

It would be a quick next step to add a build tool like Webpack, and have it in `watch mode` on your source directly, to rebuild a minified `build` folder on save.  Simply mount the `build` folder as a volume.  When ready to deploy, run the docker compose file that adds the `build` directory to the image.  I haven't actually tried this but it all clicks in my head!  and I may cover it in a future post. 

[here's the commits for this post](https://github.com/lombardo-chcg/nginx-docker/commit/7155e797f0c0e496e525d1a8fa1b2a369b9f5af6)
