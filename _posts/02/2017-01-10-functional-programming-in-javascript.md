---
layout: post
title:  "functional programming in javascript"
date:   2017-01-10 22:29:40
categories: languages
excerpt: some words of wisdom from Luis Atencio
tags:
  - functional programming
  - javascript
---

I've been reading *Functional Programming in JavaScript* by Luis Atencio.  It is a well-written introduction to the principles of functional programming aimed at an audience that is already familiar with JS.  

It's a great book and I plan to share more knowledge gleaned from it.  For now these quotes to start:

> Imperative programming treats a computer program as merely a sequence of top-to-bottom statements that changes the state of the system in order to compute a result.

> Functional programming falls under the umbrella of declarative programming paradigms: it's a paradigm that expresses a set of operations without revealing how they're implemented or how data flows through them

He provides an example of squaring all the numbers in an array.  In the classic imperative style, it is a `for` loop where the programmer tells the computer (in painfully verbose detail) how to perform the task. The programmer has to keep track of a counter, access a collection by index to mutate the data (possibly corrupting other parts of the application that depend on that data), and some other annoying things.

Compare to a functional implementation using the `map` function, where we call `map` on a collection and provide a function that encapsulates the behavior we want to perform on each item.  By abstracting away the implementation of the looping procedure to the map function, we are left with cleaner, more readable and more reusable code.
