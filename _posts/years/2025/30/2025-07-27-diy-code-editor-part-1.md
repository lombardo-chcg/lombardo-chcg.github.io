---
layout: post
title:  DIY AI Coding Assistant - Part 1
date:   2025-07-27 16:54:48
categories: tools
excerpt: "Creating an LLM-based coding assistant from scratch"
tags:
  - LLM
  - AI
  - Python
  - BAML
---

AI coding assistants like [Cursor](https://cursor.com/en) and [Github Copilot](https://github.com/features/copilot) have had a major impact on developer workflows over the last few years.  At first, their power can seem magical.  The purpose of this series is to clear away the magic and understand the basics at work.

This post is my riff on [How to Build an Agent or: The Emperor Has No Clothes](https://ampcode.com/how-to-build-an-agent) by Thorsten Ball.  Do yourself a favor and read over that post first.

My goal is to follow along using a different tech stack (Python, [BAML](https://docs.boundaryml.com/home)), as I learn best in a hands-on setting.


# Principles

- LLMs are probabilistic text-generating machines.  These machines are tuned by their creators to respect something called "tool use".  Make sure to read the `A First Tool` section in the [linked blog post]((https://ampcode.com/how-to-build-an-agent)) to understand a "tool" in this context.
- Given a set of file-system tools and a `while` loop, it is surprisingly easy to build a remarkably capable coding assistant

# Tech Stack

For this exercise I am going to use a LLM prompting DSL called [BAML](https://docs.boundaryml.com/home).  BAML is a handy wrapper around LLM interactions.  It has a smooth & natural DSL, which encourages the developer to think about LLM prompts as functions, with typed inputs and outputs.  Coming from a Scala background, thinking about LLM prompts as functions with proper input and output types is very appealing and I was immediately attracted to this project.

BAML's utility might not be readily apparent at first glance, but I suggest you spend a few minutes to watch the introduction video on their site to get a feel for its place in an LLM-enabled application.

# Prerequisites

- `uv` - the best way to manage Python projects, in my humble opinion
- `baml` plugin running in your text editor.  Their plugin is a DevEx masterpiece and enables me to get into the zone for focused iteration.  It is one of the best parts of developing with BAML.  I'm using the VS Code plugin.  Refer to [their site](https://docs.boundaryml.com/guide/introduction/what-is-baml) for install info.

```shell
uv init
uv add baml-py==0.202.1 # pinning for this example, YMMV
```

# Tool Definition




