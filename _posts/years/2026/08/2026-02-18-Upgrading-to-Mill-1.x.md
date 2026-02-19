---
layout: post
title:  "Upgrading to Mill 1.x"
date:   2026-02-18 18:41:43
categories: tools
excerpt: "Upgrade a Mill-based Scala project from 0.x to 1.x"
tags:
  - scala
  - mill
  - build tools
---

I recently upgraded a Scala library from Mill `0.12.10` -> `1.1.2`, and it took a bit longer than I was expecting to nail the syntax.  Here's a reference commit that shows how to migrate a project.

First, upgrade the mill file:
```bash
# get the current version from https://mill-build.org/mill/cli/installation-ide.html
curl -L https://repo1.maven.org/maven2/com/lihaoyi/mill-dist/1.1.2/mill-dist-1.1.2-mill.sh -o mill
```

The naming convention has changed for the build file as well: `build.sc -> build.mill`.  [There's also a `yaml` syntax now for the build file](https://mill-build.org/mill/comparisons/maven.html#_mills_simpler_declarative_builds), but I wrangle enough `yaml` in my day job so I decided to stick with the build script.

Then there are few syntax changes as well in the build file.  [Those can be seen here for reference](https://github.com/lombardo-chcg/websocket-scala/pull/14/changes#diff-2b601da62851663bf0f9429195310d82df029448cc2f404c421798601585fb10).

Here's the current file for reference: [https://github.com/lombardo-chcg/websocket-scala/blob/main/build.mill](https://github.com/lombardo-chcg/websocket-scala/blob/main/build.mill)