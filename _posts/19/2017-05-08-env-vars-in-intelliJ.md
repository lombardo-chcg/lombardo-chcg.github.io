---
layout: post
title:  "env vars in intelliJ"
date:   2017-05-08 19:27:34
categories: tools
excerpt: "using environmental variables with IntelliJ"
tags:
  - java
  - scala
  - bash
---

In my ongoing [Scalatra+Docker+Postgres](https://github.com/lombardo-chcg/scalatra-docker) project, I am doing my development with IntelliJ.  IntelliJ is a fantastic tool for working with the JVM ecosystem and I am a big fan.  

I got stuck trying to inject environmental variables into my app however (specifically Postgres connection info).  I am used to injecting variables thru standard bash `export` statements, which make the variables available to sub-processes.  However that wasn't working with IntelliJ.

The reason for injecting them is to allow the code to run locally, or to run in a Docker container, and not know or care what the Postgres connection details are, just know that it can count on them being there.  

Today I learned that these can be added thru an IntelliJ Run Configuration.  From [the docs](https://www.jetbrains.com/help/idea/2017.1/run-debug-configuration.html):

> When you perform run, debug, or test operations with IntelliJ IDEA, you always start a process based on one of the existing configurations using its parameters.

The key there is that "you always start a process" based on a run config.  Therefore, the env vars need to be present inside that process.

Luckily they make it easy to inject variables by editing a run configuration, and now my code is working as I intended.

![intellij screen grab]({{ full_base_url }}/media/intellij.png)
