---
layout: post
title:  "coding at right angles"
date:   2017-04-04 20:51:34
categories: wisdom
excerpt: "on the benefits of being orthogonal"
tags:
  - design
  - architecture
---

> **orthogonal** - intersecting or lying at right angles; having perpendicular slopes or tangents at the point of intersection

> -[merriam-webster](https://www.merriam-webster.com/dictionary/orthogonal)

The awkward-sounding word *orthogonal* represents a key concept in the domain of application design: having modular components.  This means that parts of a system are designed in such a way that they have clear points of intersection and can move independently.

For me one way towards this goal is to have clear contract definitions between components.  This can be done on the application level thru [Pact tests](https://docs.pact.io/) or inside applications with smart unit testing.

Having some experience with monolithic, highly-coupled code bases, I can speak to the pain involved in trying to expand these systems or swap out components.  The dependencies can spread throughout the intertwined applications and it can be nearly impossible to make a clean break.  This is one of the strong draws of microservice architecture.  If all a service depends on from another service is that it honor a specific contract, then either service *should* be able to be swapped out or change major parts of its own internal implementation without impacting the other system, as long as the contract is honored.

Obviously this all sounds great in theory, and the reality of writing software can quickly complicate things.  But, it is still a principle to keep in mind no matter the size of the project.
