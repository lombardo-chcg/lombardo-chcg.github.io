---
layout: post
title:  "Discord Bot in Scala"
date:   2025-06-20 06:38:45
categories: tools
excerpt: "Create a Discord Bot using the websocket-scala library"
tags:
  - scala
  - websocket
  - discord
  - streaming
---

Here's a basic recipe for creating a Discord bot using my [`websocket-scala`](https://github.com/lombardo-chcg/websocket-scala) library.  We'll be connecting to the [Gateway API](https://discord.com/developers/docs/events/gateway) and performing a basic `echo` test.

Dependencies for this tutorial in Mill format:
```scala
override def ivyDeps = Agg(
  ivy"com.lihaoyi::upickle:4.2.1",
  ivy"com.lihaoyi::requests:0.9.0"
)
```

## Creating a Bot

Create a bot with this tutorial: [https://www.writebots.com/discord-bot-token/](https://www.writebots.com/discord-bot-token/).  

Ensure you follow all the steps like granting the needed "Bot Permissions" (`Send Messages`, `Read Message History`).  

When done, capture your bot token.

## Gateway Events

> [Doc Reference](https://discord.com/developers/docs/events/gateway#gateway-events)

All events on the connection will be wrapped in a standard payload.  Here's a Scala case class to represent it: 

```scala
import upickle.default._
import ujson.Value

case class GatewayEventPayload(
    op: Int,          // Gateway opcode
    d: Value,         // Event data JSON, typed as ujson.Value
    s: Option[Int],   // Sequence number of event used for resuming sessions and heartbeating
    t: Option[String] // Event name
) {
  // also provide some aliases
  def opCode            = op
  def data              = d
  def sequenceNumberOpt = s
  def eventName         = t
}
implicit val gatewayEventRW: ReadWriter[GatewayEventPayload] = macroRW
```

For now we will just leave a generic JSON value in the `d` field.  For a real implementation, a sum type (sealed trait) to represent that field would be more appropriate. 


## Connecting

> [Doc Reference](https://discord.com/developers/docs/events/gateway#connecting)

The docs mention to invoke a `Get Gateway` endpoint to obtain the websocket endpoint.   For the purposes of the example, we will just use a hard-coded endpoint.  Here's a request to obtain that endpoint dynamically for future reference:

```sh
BOT_TOKEN='GET_YOUR_OWN'
curl --header "Authorization: Bot $BOT_TOKEN" https://discord.com/api/gateway/bot
```

This example will use `wss://gateway.discord.gg/?v=10&encoding=json`.  As per the docs, we include the API version and encoding as query parameters.


### Hello Event & Scheduled Heartbeats

 > [Doc Reference](https://discord.com/developers/docs/events/gateway#heartbeat-interval)

After the initial connection, the server will respond with a `Hello` event which contains a heartbeat interval.  We need to use that interval to set up a scheduled job that will keep heartbeats going and thus help maintain the connection.

Additionally, gateway events may include a sequence number.  When they do, we need to record the sequence number and use it on subsequent heartbeat messages.

Domain objects:
```scala
// incoming heartbeat message
case class HelloData(heartbeat_interval: Int)
implicit val helloDataRW: ReadWriter[HelloData] = macroRW

// outgoing heartbeat message (using opcode default)
case class HeartbeatPayload(op: Int = 1, d: Option[Int])
implicit val heartbeatPayloadRW: ReadWriter[HeartbeatPayload] = macroRW
```

To start the heartbeat chain, the docs specify a jitter component:
> Upon receiving the Hello event, your app should wait heartbeat_interval * jitter where jitter is any random value between 0 and 1, then send its first Heartbeat (opcode 1) event

Let's set up our heartbeat machinery using the Java `Timer` facility:
```scala
import java.util.Timer
import java.util.TimerTask

// Mutable state for this example
private var sequenceNumber: Option[Int]      = None
private val heartbeatTimer                   = new Timer()
private var heartbeatTask: Option[TimerTask] = None
private val jitterMs: Long                   = (scala.util.Random.between(0.0, 1.0) * 1000).toLong
```


Let's start building up our [Websocket Behavior](https://github.com/lombardo-chcg/websocket-scala?tab=readme-ov-file#step-1---define-a-websocketbehavior) instance to process the hello event and start the heartbeat cycle. 

```scala
val b = WebsocketBehavior.empty
  .setOnOpen(_ => println("WebSocket connection opened."))
    .setOnMessage { (socket, message) =>
      // Parse the incoming message using uPickle
      val gatewayEvent = read[GatewayEventPayload](message.value)

      // Update the sequence number if present
      gatewayEvent.sequenceNumberOpt.foreach(newSequenceNumber => sequenceNumber = Some(newSequenceNumber))

      // Handle Payloads based on Opcode
      gatewayEvent.op match {
        // Opcode 10: Hello - Sent on initial connection.
        case 10 =>
          println(s"Received Hello from Discord, scheduling reply in $jitterMs ms")
          val hello = read[HelloData](gatewayEvent.data) 

          // Start sending heartbeats at the specified interval
          val task = new TimerTask {
            def run(): Unit = {
              val heartbeat = HeartbeatPayload(sequenceNumber)
              socket.send(write(heartbeat))
              println(s"Sent Heartbeat with sequence: $sequenceNumber")
            }
          }
          // Use the jitter value as the initial delay
          heartbeatTimer.scheduleAtFixedRate(task, jitterMs, hello.heartbeat_interval)
          // Store the task so it can be cleanly cancelled later if needed.
          heartbeatTask = Some(task)


        // Opcode 11: Heartbeat ACK - Confirms the heartbeat was received.
        case 11 =>
          println(s"Received Heartbeat ACK. ${message.value}")



        // Other opcodes can be handled here
        case _ =>
          println(s"Received unhandled opcode: ${gatewayEvent.op}")
      }
    }

```

## Identifying

## Recieving Messages

## Posting Messages