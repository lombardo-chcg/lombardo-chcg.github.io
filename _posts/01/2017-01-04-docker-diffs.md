---
layout: post
title:  "docker diffs"
date:   2017-01-04 22:08:40
categories: environment
excerpt: "quirk revealed in Docker Toolbox, does it exist on Docker for Mac?"
tags:
  - docker
---

I have gained a ton of experience with Docker over the last few months and I really
like the technology.  

Today I found a little quirk.

I am running Docker Toolbox on my Mac (not Docker for Mac...).  I have heard mixed reviews of Docker for Mac but haven't tried it myself.

Today, I spun up a container for this application I am working on and tried to
interact with an external service.  Basically tried to have my container call
an external API.  

No dice.

The container was not able to interact with the service.  But when I spun up a
containerized version of the service and pointed my application at that, all good.

Is this an edge use case?  When developing using Docker, should I have every
single dependency running locally in a container?  Sure seems that way based on
this quirk.

I heard that this is a specific limitation of Docker Toolbox, and this problem does not
exist on Docker for Mac.  I am planning to find out for myself.  Stay tuned for that report...

### TL;DR
Docker is cool.  I am a fan.

Docker Toolbox has a weird limitation that prevented one of my containers from
interacting with an external dependency.  The issue was resolved by running the
dependency in another Docker container.  Going to try on Docker for Mac and report back.
