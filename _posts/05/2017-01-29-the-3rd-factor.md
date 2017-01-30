---
layout: post
title:  "the 3rd factor"
date:   2017-01-29 20:45:05
categories: "environment"
excerpt: "discussing config, the 3rd factor of a 12 factor app"
tags:
  - 12factor
---

I recently spent a good chunk of time refactoring an older application.  This app had a big problem in that it depended on many external http services, but those http endpoints where all hardcoded into the application code.  This was causing all kinds of problems at deployment time. Basically, the code had no flexibility once it left version control and became an artifact to be deployed.  The app was a lumbering, static monolith.

This problem was solved by removing the hardcoded endpoints from the application code and injecting them at runtime as environmental variables.  This provided a clean interface between the application and its environment.  It was one of those aha moments for me, where the idea is just so solid that it clicks, and so obvious that I wondered, "why isn't every app done this way?"  And I am happy to report that the application is functioning much better than its previous state since the refactoring.

--

Apparently I am not the first one for which it clicked.  The folks over at Heroku have put together the [12 Factor App](https://12factor.net/) manifesto, which I was casually reading earlier today.  Previously I had known 12 Factor as a Ruby gem that was required to deploy a Rails server to Heroku, but I didn't know much past the gem.

The 3rd Factor is exactly what I realized after refactoring the above-mentioned app.  Here are the highlights of the 3rd factor:

**III.  Config**
* Apps sometimes store config as constants in the code.  This is a violation of twelve-factor, which requires strict separation of config from code.
* The twelve-factor app stores config in environment variables.
* Environmental Variables (env vars) are granular controls

That last one is especially important.  It means that each external dependency is specified on a individual level.  This is in opposition to the model of grouping all dependencies into a single block, such as "development" or "production".  Grouping in env blocks leaves the application open to the same issues I mentioned above, mainly a fragile state and lack of flexibility.  It cancels out the effectiveness of extrapolating the dependencies to begin with.

12 Factor?  So far, so good.  I look forward to diving in further and writing more about it too.
