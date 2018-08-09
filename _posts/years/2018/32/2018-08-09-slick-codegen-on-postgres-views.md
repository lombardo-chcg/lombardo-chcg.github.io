---
layout: post
title:  "slick codegen on postgres views"
date:   2018-08-09 16:49:55
categories: tools
excerpt: "auto-generating slick schemas based on Postgres Views"
tags:
  - sql
  - scala
  - slick
  - postgres
---

[Slick](http://slick.lightbend.com/doc/3.2.3/gettingstarted.html#schema) has become my favorite library for doing SQL with Scala.  

The [Schema Code Generator](http://slick.lightbend.com/doc/3.2.3/code-generation.html) is especially powerful - just point it at a database and it generates the needed code to access the db using the Slick DSL.

I found that when using this feature with Postgres, only tables types were processed by the code generator - not [views](https://www.postgresql.org/docs/9.2/static/sql-createview.html).  So here's a standalone [Ammonite
](https://github.com/lihaoyi/Ammonite) script that contains the code needed to auto-produce Slick schemas that cover  PG tables & views.

*credit to [https://coderwall.com/p/hdcolg/slick-3-1-1-codegen-for-views](https://coderwall.com/p/hdcolg/slick-3-1-1-codegen-for-views) for sending me down the right path on this one*

{% highlight scala %}
/*
  This is an Ammonite Script
  http://ammonite.io/#Ammonite

  must be run with amm shell command
*/

import ammonite.ops.pwd

import $ivy.{
  `com.typesafe.slick:slick-codegen_2.12:3.2.3`,
  `com.typesafe.slick:slick_2.12:3.2.3`,
  `org.postgresql:postgresql:9.4.1212`
}

import slick.codegen.SourceCodeGenerator
import slick.driver.PostgresDriver
import slick.driver.PostgresDriver.api._
import slick.jdbc.meta._

import scala.concurrent.Await
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.duration._

val	url = "jdbc:postgresql://localhost:5432/postgres"
val	user = "postgres"
val	password = "postgres"
val db = Database.forURL(url, user, password)

// this call appears to be a wrapper around java.sql.DatabaseMetaData.getTables()
//  https://docs.oracle.com/javase/7/docs/api/java/sql/DatabaseMetaData.html#getTables(java.lang.String,%20java.lang.String,%20java.lang.String,%20java.lang.String[])
val tablesAndViews = MTable.getTables(None, None, None, Some(Seq("TABLE", "VIEW")))

val modelAction = PostgresDriver.createModel(Some(tablesAndViews))
val model = Await.result(db.run(modelAction), 5 seconds)
val codeGen = new SourceCodeGenerator(model)

/**
	* @param profile Slick profile that is imported in the generated package (e.g. slick.jdbc.H2Profile)
	* @param folder target folder, in which the package structure folders are placed
	* @param pkg Scala package the generated code is placed in (a subfolder structure will be created within srcFolder)
	* @param container The name of a trait and an object the generated code will be placed in within the specified package.
	* @param fileName Name of the output file, to which the code will be written
	(source: https://github.com/slick/slick/blob/47ab0e701d2785d563f2f7ad4e9584e66cc17f38/slick-codegen/src/main/scala/slick/codegen/OutputHelpers.scala#L46)
*/
codeGen.writeToFile(
	profile = "slick.driver.PostgresDriver",
	folder = pwd.toString,
	pkg = "com.example",
	container = "TablesAndViews",
	fileName ="TablesAndViews.scala"
)
{% endhighlight %}
