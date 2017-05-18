---
layout: post
title:  "postgres vs. redis"
date:   2017-05-17 21:40:04
categories: databases
excerpt: "comparing read performance of pg and redis"
tags:
  - sql
  - nosql
---

So I have not posted in a long time regarding my Scalatra-Postgres / Scrabble-helper API project.  But I have been doing tons of work on it and having a blast.  Since the last time I posted I have done tons of stuff.  But I realized that Postgres/SQL was not the right db technology for the job.  Looking up many combinations of letters as fast as possible does not require the benefits that Postgres providers (i.e. relational querying)

I decided to mess around with Redis instead and the results are staggering.  I plan to post more but here is a quick preview of the differences in performance.

* Word provided by the user: `abcdefg`
* Number of database queries required to account for all possible letter combinations: `127`
* Number of English words that can be constructed from that letter combination: `52`
* Performance comparison: 
* * Postgres: `elapsed time 3736 ms`
* * Redis: `elapsed time 281 ms`
