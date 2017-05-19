---
layout: post
title:  "disk usage"
date:   2017-05-18 21:17:29
categories: tools
excerpt: "getting a quick handle on disk usage stats with bash"
tags:
  - bash
---

Q: I just spent 20 minutes downloading dependencies for this project.  How much disk space does it take up? 

A: `du -hs dir_name/`

Or if you are already inside the directory in question just `du -hs`

`-h` for human readable output, `-s` for summary mode (so the terminal output is only a single line)
