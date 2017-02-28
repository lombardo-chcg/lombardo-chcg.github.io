---
layout: post
title:  "idempotent endpoints"
date:   2017-02-27 22:05:40
categories: web-programming
excerpt: "providing safe endpoints for your api consumers"
tags:
  - REST
---

I've come across the term idempotent before but I wanted to crystallize it in a blog post (mostly because I remember the concept, but can't always remember the term).

An idempotent endpoint is one that is safe, meaning it be called multiple times without negatively impacting the resource.

For example, imagine a workflow where a database entry is created as a side effect of a main workflow.  Perhaps when a user updates their profile, we also send a PUT request to update their subscription status for a newsletter.

If they are already subscribed, and we send a PUT to add the subscription, a non-idempotent endpoint may freak out and not be happy with the redundant request.  An idempotent endpoint would simply discard the request and return a 200-level status as if the request were happily processed.

Idempotent endpoints provide flexibility and prevent nasty try/catch style coding from creeping into the api consumer.
