---
layout: post
title:  "react + docker, part 2"
date:   2017-08-16 20:24:06
categories: tools
excerpt: "let's finish dockerizing an app made with facebook's create-react-app tool"
tags:
- react
- javascript
- jsx
- docker
- express
- node
---

In [part 1](/tools/2017/08/13/react-+-docker.html) we created a basic javascript server that will serve up our React web app.  Now we need to "containizer" the app using Docker.

As a reminder of our basic workflow:

1. ~~create a simple server using [express](https://expressjs.com/) that will serve up the static UI content based based on an http request~~
2. After finishing up the UI work, use the `create-react-app` build script to create a "productionized" version of the React app
3. combine both pieces into a docker image

For step two, creating a production build with the create-react-app tool is as simple as running a script: `npm run build`

Now to part three.  Since a JS project's [`node_modules` can be amongst the largest around](https://me.me/i/sun-neutron-star-black-hole-node-modules-heaviest-objects-in-the-18237134), and the necessary components were already compiled as part of the build step, it makes sense to skip those in our Docker build process.  This way, the "build context" that is passed to the Docker daemon doesn't include a bunch of junk we don't need.  We can specify that in a `.dockerignore` file at the project root:

{% highlight bash %}
/node_modules
/server/node_modules
{% endhighlight %}

Now for the Dockerfile.  Here's an annotated version explaining all the steps:

{% highlight bash %}
# start from a slim node base image
FROM node:alpine

# create directory for our project files
RUN mkdir src/

# copy over the node server code and our bundled React app content
COPY /server/main.js /src/server/main.js
COPY /server/package.json /src/server/package.json
COPY /build /src/server/build

# set the Docker working directory
WORKDIR /src/server

# install dependencies for our express server
RUN npm install

# tell the docker container which port to listen to at runtime
EXPOSE 9000

# provide the command to start the server within the container
# this command will run automatically when the container is started
# the node process is creates becomes PID 1 - the top of the Unix process tree inside our container
CMD node main.js
{% endhighlight %}

All that's left to do now is run it!

{% highlight bash %}
docker build -t example-react-app .

# expose container port 9000 as docker host port 80
docker run -p "80:9000" example-react-app:latest
{% endhighlight %}

`localhost` in any browser will show the React app.

And to prove the proxy is working, try `curl localhost/proxy` from a terminal and you should see Google's page content.  Now just point that proxy target at your backend server and don't sweat the CORS. 
