---
layout: post
title:  "dependency injection using scaldi"
date:   2017-07-22 09:44:08
categories: languages
excerpt: "quick note on a dependency injection library for scala"
tags:
  - scala
  - scalatra
  - Solid
---

Dependency Injection is part of the SOLID design principles (specifically the D: Dependency Inversion Principle).

To understand the concept behind DI, [Dr. Wikipedia provides a great article](https://en.wikipedia.org/wiki/Dependency_injection) (skip to the sidebar entitled *Dependency injection for five-year-olds*)

There are many, well-documented arguments out there regarding why to use Dependency Injection.  For me, one of the best reasons is for unit testing.  The ability to stub out dependencies and focus on single functional modules of code is enough for me to buy in.

While using a popular Scala DI library called [`Scaldi`](https://github.com/scaldi/scaldi) I came across a specific need: there was one service that needed to be "newed up" every time it was injected.  The more common pattern in DI is that there is one "instance" of a object instantiated for the entire application, and that instance is provided to anyone who asks for it.  

For my use case, the service had a piece of internal state that needed to be unique for each caller of the service.  So, each caller needed its own copy of the service.

`Scaldi` handles this nicely with its [binding overrides](http://scaldi.org/learn/#binding-overrides) which are used inside the Injector provider:

{% highlight scala %}
bind [Server] to new HttpServer
{% endhighlight %}

While this may look like it is creating a new instance for each binding, it is actually not.  It creates a single instance and then reuses it.  To get a new instance for each binding, follow this pattern, using the `toProvider` key word:

{% highlight scala %}
bind [UserService] toProvider new UserService
{% endhighlight %}

The `to` keyword provides lazy binding, and `toNonLazy` is also available.
