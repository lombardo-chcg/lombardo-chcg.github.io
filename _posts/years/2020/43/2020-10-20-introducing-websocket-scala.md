---
layout: post
title:  "introducing websocket-scala"
date:   2020-10-20 20:21:47
categories: tools
excerpt: "a simple websocket library for scala"
tags:
  - scala
  - websocket
  - javascript
  - streaming
---

My first introduction to [Websockets](https://en.wikipedia.org/wiki/WebSocket) was using the vanilla JavaScript [`WebSocket` object](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API) while making a web page a few years back.  IMO the native JS `WebSocket` provides an extremely intuitive API for handling duplex communication with a server.

In a Scala context, WebSocket client interactions can be much less intuitive.  I have used several libraries and they all required me to learn new abstractions and buy into much larger frameworks and patterns in order to perform simple WebSocket client tasks.  Where was my basic, event-driven Scala `WebSocket` client??

I could not find it so I decided to create it myself.

Introducing [`websocket-scala`](https://github.com/lombardo-chcg/websocket-scala)!

> websocket-scala is a simple Scala Websocket client library. It is based on the WebSocket interface as defined in the MDN web docs, which is available as a JavaScript object in HTML5-compliant web browsers. The goal of the library is to provide the same simple & intuitive Websocket client api for JVM Scala apps.

This is far from a purely-functional Scala library.  Don't get me wrong - I adore the beauty and structure that is possible in Functional Programming.  But sometimes I just need to get something done quickly and efficiently.  Less FP, more GSD (getting shit done).  In this way, I am highly inspired by the [Li Haoyi](https://github.com/lihaoyi) style of Scala - simple, ultra-pragmatic, and extremely powerful.  Therefore I fully embrace the [JavaScript `WebSocket` API](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API) for what it is - a simple, effective way to manage a websocket connection.

Here's an example of how to connect to the [Coinbase public websocket feed](https://docs.pro.coinbase.com/?javascript#websocket-feed) and stream ticker data for 15 seconds using an [Ammonite](https://ammonite.io/) repl session:

```scala
import $ivy.`net.domlom::websocket-scala:0.0.3`

import net.domlom.websocket._

val url = "wss://ws-feed.pro.coinbase.com"

val connectionJson =
  s"""
     |{
     |    "type": "subscribe",
     |    "channels": [{ "name": "ticker", "product_ids": ["BTC-USD"] }]
     |}
 """.stripMargin

val behavior = {
  WebsocketBehavior.debugBehavior
    .setOnOpen(sock => sock.send(connectionJson))
}

val socket = Websocket(url, behavior)

println {
  for {
    _ <- socket.connect()
    _ = Thread.sleep(15000)
    r <- socket.close()
  } yield r
}
```
