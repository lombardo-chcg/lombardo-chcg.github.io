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
---

My first introduction to [WebSockets](https://en.wikipedia.org/wiki/WebSocket) was using the native JavaScript [`WebSocket` object](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API) while programming for web.  IMO the native JS `WebSocket` is an extremely intuitive API for handling streaming data.

In a Scala context, WebSocket client interactions are much less intuitive.  I have used several libraries and they all required me to learn new abstractions and use overly-powerful tooling to perform simple WebSocket client tasks.  Where was my basic, event-driven Scala `WebSocket` client API?

I could not find one so I decided to create it myself.

Introducing [`websocket-scala`](https://github.com/lombardo-chcg/websocket-scala)!

> websocket-scala is a simple Scala Websocket client library. It is based on the WebSocket interface as defined in the MDN web docs, which is available as a JavaScript object in HTML5-compliant web browsers. The goal of the library is to provide the same simple & intuitive Websocket client api for JVM Scala apps.

This API is far from functional, and that's ok.  I fully embrace the JS API for what it is - a simple, effective way to manage a duplex communication channel with a WebSocket server. 

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
