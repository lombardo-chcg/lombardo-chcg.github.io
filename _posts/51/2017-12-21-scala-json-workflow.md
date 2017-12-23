---
layout: post
title:  "scala json workflow"
date:   2017-12-21 15:17:14
categories: "tools"
excerpt: "setting up a local JSON exploration sandbox REPL in Scala"
tags:
  - Scala
  - json
  - json4s
  - amm
  - repl
  - jvm
  - avro
  - apache
---

While exploring a new JSON API, I like to get quick feedback on how the API response information is organized and how to work with the data.  Useful tools for this task in a Scala context are [json4s](https://github.com/json4s/json4s) and [scalaj-http](https://github.com/scalaj/scalaj-http)

Here's a quick way to set up an [Ammonite-REPL session](http://ammonite.io/#Ammonite-REPL) with those dependencies for supercharged JSON sandboxing.

--

*Prerequisite: install the wonderful [amm REPL](http://ammonite.io/#Ammonite-REPL)*

Enter a REPL session by typing `amm` from the terminal.  You can enter the following commands one by one, or just copy-and-paste the whole blob to load up all the dependencies and get moving quickly.

{% highlight scala %}
// Welcome to the Ammonite Repl 1.0.0
// (Scala 2.12.2 Java 1.8.0_152)\

// NOTE THAT SCALA VERSION in the inital output
// Use the scala version in the import statements:

import $ivy.`org.json4s:json4s-ext_2.12:3.5.0`
import $ivy.`org.json4s:json4s-jackson_2.12:3.5.0`
import $ivy.`org.json4s:json4s-native_2.12:3.5.0`
import $ivy.`org.scalaj:scalaj-http_2.12:2.3.0`

import org.json4s._
import org.json4s.native.JsonMethods._
import org.json4s.JsonDSL._
import scalaj.http.Http

implicit val formats = org.json4s.DefaultFormats

// grab some sample JSON
val response =  Http("https://jsonplaceholder.typicode.com/posts/1").asString

val parsedResponse = parse(response.body)
val articleTitle = (parsedResponse \\ "title").extract[String]

case class Post(userId: Int, id: Int, title: String, body: String)
val post = parsedResponse.extract[Post]

{% endhighlight %}

Add some Avro to the mix:
{% highlight scala %}
import $ivy.`org.apache.avro:avro:1.8.2`

import org.apache.avro.generic.GenericData
import org.apache.avro.Schema.Parser

val schemaParser = new Parser
val schemaJson =
s"""
  {
    "namespace": "com.avro.junkie",
    "type": "record",
    "name": "User2",
    "fields": [
      {"name": "name", "type": "string"},
      {"name": "favoriteNumber",  "type": "int"},
      {"name": "favoriteColor", "type": "string"}
    ]
  }
"""
val avroSchema = schemaParser.parse(schemaJson)
val avroRecord = new GenericData.Record(avroSchema)
avroRecord.put("name", "mary")
avroRecord.put("favoriteNumber", 11)
avroRecord.put("favoriteColor", "green")

avroRecord.toString

// bring it all together - go from Avro to JSON AST

parse(avroRecord.toString)

{% endhighlight %}
