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
  ivy"net.domlom::websocket-scala:0.0.4",
  ivy"com.lihaoyi::upickle:4.2.1",
  ivy"com.lihaoyi::requests:0.9.0"
)
```

Imports needed:
```scala
import net.domlom.websocket.Websocket
import net.domlom.websocket.WebsocketBehavior

import java.net.URI
import java.util.Timer
import java.util.TimerTask

import upickle.default._
import ujson.Value
```


## Creating a Bot

Create a bot with this tutorial: [https://www.writebots.com/discord-bot-token/](https://www.writebots.com/discord-bot-token/).  

Ensure you follow all the steps like granting the needed "Bot Permissions" (`Send Messages`, `Read Message History`).  

Additionally, we want to enable `Privileged Gateway Intents`, which will allow our Bot to read the contents of all messages.  Instructions here: [https://discord.com/developers/docs/events/gateway#enabling-privileged-intents](https://discord.com/developers/docs/events/gateway#enabling-privileged-intents)

When done, capture your bot token along with your bot name for later use.
```scala
val BOT_TOKEN = "REPLACE_ME"
val BOT_NAME = "REPLACE_ME"
```

## Gateway Events

> [Doc Reference](https://discord.com/developers/docs/events/gateway#gateway-events)

Once we complete the connection, we will start receiving events from Discord.  All events on the connection will be wrapped in a standard payload (both incoming and outgoing).  Here's a Scala case class to represent it along with the upickle JSON plumbing:

```scala
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

object GatewayEventPayload {
  implicit val gatewayEventRW: ReadWriter[GatewayEventPayload] = macroRW
}
```

For now we will just leave a generic JSON value in the `d` field and a string in the `t` field.  For a real implementation, using sum types (sealed trait for the data, enum for the event name) would be more appropriate.


## OpCodes

Each gateway event will contain an [OpCode](https://discord.com/developers/docs/topics/opcodes-and-status-codes#opcodes-and-status-codes) (int) to identify itself.  Here's the ones we care about for this example:
```scala
object OpCode {
  val EVENT_DISPATCH = 0
  val HEARTBEAT      = 1
  val IDENTIFY       = 2
  val HELLO          = 10
  val HEARTBEAT_ACK  = 11
}
```

## Connecting

> [Doc Reference](https://discord.com/developers/docs/events/gateway#connecting)

The docs mention to invoke a `Get Gateway` [endpoint](https://discord.com/api/gateway/bot) to obtain the websocket endpoint.   For the purposes of the example, we will just use a hard-coded endpoint:

`wss://gateway.discord.gg/?v=10&encoding=json`

As per the docs, we include the API version and encoding as query parameters.


### Hello Event & Scheduled Heartbeats

 > [Doc Reference](https://discord.com/developers/docs/events/gateway#heartbeat-interval)

After the initial connection, the server will respond with a `Hello` event which contains a heartbeat interval.  We need to use that interval to set up a scheduled job that will keep heartbeats going and thus help maintain the connection.

Additionally, gateway events may include a sequence number.  When they do, we need to record the sequence number and use it on subsequent heartbeat messages.

The heartbeat message can be send using the `GatewayEventPayload` defined above.
```scala
// incoming heartbeat message
case class HelloData(heartbeat_interval: Int)
implicit val helloDataRW: ReadWriter[HelloData] = macroRW

// outgoing heartbeat message (using a helper method to create a GatewayEventPayload)
def heartbeat(sequenceNumber: Option[Int]) =
  GatewayEventPayload(op = HEARTBEAT, writeJs(sequenceNumber), s = None, t = None)
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
      gatewayEvent.sequenceNumberOpt.foreach(newSeqNum => sequenceNumber = Some(newSeqNum))

      // Handle Payloads based on Opcode
      gatewayEvent.op match {
        // Sent on initial connection.
        case OpCode.HELLO =>
          println(s"Received Hello from Discord, scheduling reply in $jitterMs ms")
          val hello = read[HelloData](gatewayEvent.data)

          // Start sending heartbeats at the specified interval
          val task = new TimerTask {
            def run(): Unit = {
              val heartbeat = GatewayEventPayload.heartbeat(sequenceNumber)
              socket.send(write(heartbeat))
              println(s"Sent Heartbeat with sequence: $sequenceNumber")
            }
          }
          heartbeatTimer.scheduleAtFixedRate(task, jitterMs, hello.heartbeat_interval)
          heartbeatTask = Some(task)

        // Confirms the heartbeat was received.
        case OpCode.HEARTBEAT_ACK =>
          println(s"Received Heartbeat ACK.")

        // An event was dispatched.
        case OpCode.EVENT_DISPATCH =>
          println(s"Received Event: ${gatewayEvent.t.getOrElse("UNKNOWN_EVENT")}")

        // Other opcodes can be handled here
        case _ =>
          println(s"Received unhandled opcode: ${gatewayEvent.op}")
      }

```

## Identifying

From the [docs](https://discord.com/developers/docs/events/gateway#identifying):

> After the connection is open and your app is sending heartbeats, you should send an Identify (opcode 2) event. The Identify event is an initial handshake with the Gateway that's required before your app can begin sending or receiving most Gateway events.

Here are case classes to represent the Identify payload:
```scala
// Opcode 2: Identify
case class IdentifyProperties(os: String, browser: String, device: String)
implicit val identifyPropertiesRW: ReadWriter[IdentifyProperties] = macroRW

case class IdentifyData(token: String, intents: Int, properties: IdentifyProperties)
implicit val identifyDataRW: ReadWriter[IdentifyData] = macroRW
```

The `intents` implementation is pretty cool.  Each intent is represented by a bit, and we can enable multiple intents by `OR`ing desired bits.  For this example we want `GUILDS`, `GUILD_MESSAGES`, and `MESSAGE_CONTENT`.

Reference the full list of intents [here](https://discord.com/developers/docs/events/gateway#list-of-intents).

```scala
val GUILDS = 1 << 0
val GUILD_MESSAGES = 1 << 9
val MESSAGE_CONTENT = 1 << 15

val intents_value = GUILDS | GUILD_MESSAGES | MESSAGE_CONTENT
// 33281
```

In the `Hello` event handler, immediately after starting the heartbeat process, send the `Identify` payload to execute a handshake and start receiving messages.
```scala
val identifyData = IdentifyData(
  token = BOT_TOKEN,
  intents = 33281,
  properties = IdentifyProperties(
    os = System.getProperty("os.name"),
    browser = "websocket-scala",
    device = "websocket-scala"
  )
)

// helper method to create a GatewayEventPayload
def identify(identifyData: IdentifyData) = GatewayEventPayload(
  op = OpCode.IDENTIFY,
  d = writeJs(identifyData),
  s = None,
  t = None
)

val identifyEvent = identify(identifyData)

socket.send(write(identifyEvent))
println("Sent Identify Payload.")
```


## Receiving Messages

Messages can be handled in our existing `gatewayEvent.op` match statement.  We will concern ourselves with `OpCode.EVENT_DISPATCH`, when the event name is `MESSAGE_CREATE`.  Just using simple uPickle direct parsing - for more robust use cases, create a case class to handle event data payloads.

```scala
case OpCode.EVENT_DISPATCH =>
  println(s"Received Event: ${gatewayEvent.eventName.getOrElse("UNKNOWN_EVENT")}")

  if (gatewayEvent.eventName.contains("MESSAGE_CREATE")) {
    val author = gatewayEvent.data("author")("username").str
    if (author != BOT_NAME) {
      val content = gatewayEvent.data("content").str
      println(s"-----MESSAGE from $author: $content")
    }
  }
```


## Posting Messages

To make our bot interactive, let's send messages back to the channel.  This is not done via the Websocket connection; it is done via standard REST.  Here's a quick example using the `requests` library:

```scala
  val channelId = gatewayEvent.data("channel_id").str
  val url       = s"https://discord.com/api/v10/channels/$channelId/messages"
  val headers   = Map(
    "Authorization" -> s"Bot $BOT_TOKEN",
    "Content-Type"  -> "application/json",
  )
  val message = "Hello from the bot"
  val messageWrapper = ujson.Obj("content" -> message)
  println(s"Sending message: $url $headers $message")
  val response = requests.post(
    url,
    headers = headers,
    data = write(messageWrapper)
  )
```

## Conclusion

And now we've got a fully-functional, `Hello World` Discord bot.  What would you build with it?

Some things to add:
- proper enums and types rather than magic strings
- reconnect/resume sessions
- slash commands
- your cool idea here

Here's the fully working example for reference:
```scala
package runnable

import net.domlom.websocket.Websocket
import net.domlom.websocket.WebsocketBehavior

import java.net.URI
import java.util.Timer
import java.util.TimerTask

import upickle.default._
import ujson.Value

// Discord Gateway OpCodes that denotes the payload type.
object OpCode {
  val EVENT_DISPATCH = 0
  val HEARTBEAT      = 1
  val IDENTIFY       = 2
  val HELLO          = 10
  val HEARTBEAT_ACK  = 11
}

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

object GatewayEventPayload {
  implicit val gatewayEventRW: ReadWriter[GatewayEventPayload] = macroRW

  def heartbeat(sequenceNumber: Option[Int]) =
    GatewayEventPayload(op = OpCode.HEARTBEAT, writeJs(sequenceNumber), s = None, t = None)

  def identify(identifyData: IdentifyData) = GatewayEventPayload(
    op = OpCode.IDENTIFY,
    d = writeJs(identifyData),
    s = None,
    t = None
  )
}

// Opcode 2: Identify
case class IdentifyProperties(os: String, browser: String, device: String)
implicit val identifyPropertiesRW: ReadWriter[IdentifyProperties] = macroRW

case class IdentifyData(token: String, intents: Int, properties: IdentifyProperties)
implicit val identifyDataRW: ReadWriter[IdentifyData] = macroRW

// Opcode 10: Hello
case class HelloData(heartbeat_interval: Int)
implicit val helloDataRW: ReadWriter[HelloData] = macroRW

object DiscordBotV2 {
  private val BOT_TOKEN = sys.env.getOrElse("BOT_TOKEN", sys.error("env var BOT_TOKEN required"))
  private val BOT_NAME  = "ws-scala-01"

  // Should be fetched as per the docs, hardcode for the example.
  private val gatewayUrl = "wss://gateway.discord.gg/?v=10&encoding=json"

  // Mutable state for the connection
  private var sequenceNumber: Option[Int]      = None
  private val heartbeatTimer                   = new Timer()
  private var heartbeatTask: Option[TimerTask] = None
  private val jitterMs: Long                   = (scala.util.Random.between(0.0, 1.0) * 1000).toLong

  // Create WS lifecycle handlers
  val b = WebsocketBehavior.empty
    .setOnOpen(_ => println("WebSocket connection opened."))
    .setOnMessage { (socket, message) =>
      // Parse the incoming message using uPickle
      val gatewayEvent = read[GatewayEventPayload](message.value)

      // Update the sequence number if present
      gatewayEvent.sequenceNumberOpt.foreach(newSeqNum => sequenceNumber = Some(newSeqNum))

      // Handle Payloads based on Opcode
      gatewayEvent.op match {
        // Sent on initial connection.
        case OpCode.HELLO =>
          println(s"Received Hello from Discord, scheduling reply in $jitterMs ms")
          val hello = read[HelloData](gatewayEvent.data)

          // Start sending heartbeats at the specified interval
          val task = new TimerTask {
            def run(): Unit = {
              val heartbeat = GatewayEventPayload.heartbeat(sequenceNumber)
              socket.send(write(heartbeat))
              println(s"Sent Heartbeat with sequence: $sequenceNumber")
            }
          }
          heartbeatTimer.scheduleAtFixedRate(task, jitterMs, hello.heartbeat_interval)
          heartbeatTask = Some(task)

          // Immediately Identify the bot to the gateway
          val identifyData = IdentifyData(
            token = BOT_TOKEN,
            intents = 33281,
            properties = IdentifyProperties(
              os = System.getProperty("os.name"),
              browser = "websocket-scala",
              device = "websocket-scala"
            )
          )
          val identifyEvent = GatewayEventPayload.identify(identifyData)
          socket.send(write(identifyEvent))
          println("Sent Identify Payload.")

        // Confirms the heartbeat was received.
        case OpCode.HEARTBEAT_ACK =>
          println(s"Received Heartbeat ACK.")

        // Handle Events (like messages in the channel)
        case OpCode.EVENT_DISPATCH =>
          println(s"Received Event: ${gatewayEvent.eventName.getOrElse("UNKNOWN_EVENT")}")

          if (gatewayEvent.eventName.contains("MESSAGE_CREATE")) {
            val author = gatewayEvent.data("author")("username").str
            if (author != BOT_NAME) {
              val content = gatewayEvent.data("content").str
              println(s"-----MESSAGE from $author: $content")

              val channelId = gatewayEvent.data("channel_id").str
              val url       = s"https://discord.com/api/v10/channels/$channelId/messages"
              val headers   = Map(
                "Authorization" -> s"Bot $BOT_TOKEN",
                "Content-Type"  -> "application/json",
              )

              val message        = s"Hello from the bot @ ${System.currentTimeMillis()}"
              val messageWrapper = ujson.Obj("content" -> message)
              println(s"Sending message: $url $message")
              val response = requests.post(
                url,
                headers = headers,
                data = write(messageWrapper)
              )
            }
          }

        // Other opcodes can be handled here
        case _ =>
          println(s"Received unhandled opcode: ${gatewayEvent.op}")
      }
    }
    .setOnClose { details =>
      println(s"WebSocket connection closed. $details")
      // Stop the heartbeat timer when the connection closes
      heartbeatTask.foreach(_.cancel())
      heartbeatTimer.cancel()
    }
    .setOnError { (sock, error) =>
      println(s"WebSocket error: ${error.getMessage}")
      error.printStackTrace()
    }

  println("Connecting to Discord Gateway...")

  val ws = Websocket(gatewayUrl, b)

  def main(args: Array[String]): Unit = {
    ws.connect()

    while (ws.isOpen) {
      // Keep the thread alive
    }
  }
}

```
