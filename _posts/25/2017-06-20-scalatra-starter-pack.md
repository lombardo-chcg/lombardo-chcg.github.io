---
layout: post
title:  "scalatra starter pack"
date:   2017-06-20 22:00:04
categories: web-programming
excerpt: "a starter kit for api development"
tags:
  - scala
  - docker
  - json
  - api
---

I have an idea for a new project which would require a basic API layer.  

I've been having lots of fun with Scala and Scalatra, but with a little customization.  So I thought why not make a little skeleton project with all the setup I like for future use as well?

Here is is: [https://github.com/lombardo-chcg/scalatra-api-skeleton](https://github.com/lombardo-chcg/scalatra-api-skeleton)

There is lots of hardcoded stuff in here when it comes to naming conventions.  So not great.  A good refactor would be to fork the [giter8 Scalatra SBT project template](https://github.com/scalatra/scalatra-sbt.g8) project and include all my favorite JSON and Docker support with the benefit of dynamic project generation.
