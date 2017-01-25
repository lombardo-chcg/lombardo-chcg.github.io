---
layout: post
title:  "vr in the browser"
date:   2017-01-24 22:06:03
categories: "mixed-bag"
excerpt: "using a javascript api to render virtual reality scenes in a browser"
tags:
  - vr
  - javascript
---

Went to a meetup tonight and took in a very cool talk about [A-Frame](https://aframe.io/docs/0.4.0/introduction/).  A-Frame is a framework on top of the WebVR api for building virtual reality apps in a browser.

The syntax really reminds me of some 'intelligent markup' such as Angular 1.x using specialized HTML tags.  From their official docs:

{% highlight html %}
<body>
  <a-scene>
    <a-box color="#6173F4" opacity="0.8" depth="2"></a-box>
    <a-sphere radius="2" src="texture.png" position="1 1 0"></a-sphere>
    <a-sky color="#ECECEC"></a-sky>
  </a-scene>
</body>
{% endhighlight %}

The talk gave some insight into the rapidly changing world of VR and how major, breaking releases are happening on a regular cadence.  The days of flat, 2-d user interfaces are numbered!

I think it is really cool that anyone with basic web development knowledge can use this open-source framework and start creating VR experiences.  The future of VR user interfaces is wide open, and open to anyone.  I am looking forward to more democratization and diversity in technology in 2017 and years to come. 
