---
layout: post
title:  "uuid collisions"
date:   2017-03-02 21:56:08
categories: mixed-bag
excerpt: "staying unique with universally unique identifiers"
tags:
  - UUID
---

I've been doing some work with UUIDs lately, and I got to thinking: what are the chances of repetition?

Quick background note: Universally unique identifiers or UUIDs are a common tool for giving a unique identity to a piece of data.  Think of them as serial numbers for information.

Apparently the chances of repeating a UUID are so small that the chance is not even be considered a risk.  The spec says ["A UUID is 128 bits long, and can guarantee uniqueness across space and time."](https://www.ietf.org/rfc/rfc4122.txt)

Wikipedia states that the total number of UUIDs is in the range of 10^36 or 1000000000000000000000000000000000000 [*source*](https://en.wikipedia.org/wiki/Orders_of_magnitude_%28numbers%29#1018)

According to that same Wikipedia page, this number is greater than number of bacterial cells on Earth and the number of atoms in the human body.
