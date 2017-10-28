---
layout: post
title:  "scala json recipes"
date:   2017-10-27 21:26:48
categories: web-programming
excerpt: "useful tips for consuming JSON in Scala with json4s"
tags:
  - scala
  - json4s
  - ast
---

Own that JSON using the powerful [json4s](https://github.com/json4s/json4s) library.

Json examples from [json-schema.org](http://json-schema.org/example1.html).

--

### Library dependencies:
(Gradle format)
{% highlight bash %}
'org.json4s:json4s-jackson_2.11:3.5.0'
'org.json4s:json4s-ext_2.10:3.5.0'
'org.json4s:json4s-native_2.11:3.5.0'
{% endhighlight %}

### imports:
{% highlight scala %}
import org.json4s._
import org.json4s.native.JsonMethods._
import org.json4s.JsonDSL._

// needed for most examples that follow:
implicit val formats = org.json4s.DefaultFormats
{% endhighlight %}

--

### When the top level is a JSON Object:
{% highlight scala %}
val jsonString = s"""
  {
    "id": 1,
    "name": "A green door",
    "price": 12.50,
    "tags": ["home", "green"]
  }
"""
{% endhighlight %}

#### 1. Parse directly into Scala

This is possible with the `org.json4s.extract` method.
Note that method's signature:

{% highlight scala %}
def extract[A](implicit formats: Formats, mf: scala.reflect.Manifest[A]): A
{% endhighlight %}

which requires an `implicit` param of type `Formats` is required.  So be sure to declare an implicit param of that type in scope of the `extract` call.

Extracting to `Map[String, Any]` seems to work for most cases:

{% highlight scala %}
implicit val formats = org.json4s.DefaultFormats

parse(jsonString).extract[Map[String, Any]]
/*
**  Map(id -> 1, name -> A green door, price -> 12.5, tags -> List(home, green))
*/
{% endhighlight %}

#### 2. Extract a field using the library DSL
{% highlight scala %}
val parsed = parse(jsonString)

parsed \\ "id"
/*
**  JInt(1)
*/

(parsed \\ "id").extract[Int]
/*
**  1
*/

parsed findField {
 case JField("id", _) => true
 case _ => false
}
/*
**  Some((id,JInt(1)))
*/

val wrappedTags = parsed \\ "tags"
wrappedTags.extract[Array[String]].toList
/*
**  List(home, green)
*/
{% endhighlight %}

#### 3. Extract a field using a case class

Leverage all the power of Scala case classes for working with data.

It is not required that the case class implement all fields of the JSON.

This is my preferred method.

{% highlight scala %}
case class Summary(name: String, tags: List[String])

parse(jsonString).extract[Summary]
/*
**  Summary(A green door, List(home, green))
*/

val summary = parse(jsonString).extract[Summary]

summary.name
/*
**  A green door
*/
{% endhighlight %}

--


### When the top level is a JSON Array of Objects:

{% highlight scala %}
val setOfProducts = s"""[
  {
      "id": 2,
      "name": "An ice sculpture",
      "price": 12.50,
      "tags": ["cold", "ice"],
      "dimensions": {
          "length": 7.0,
          "width": 12.0,
          "height": 9.5
      }
  },
  {
      "id": 3,
      "name": "A blue mouse",
      "price": 25.50,
      "dimensions": {
          "length": 3.1,
          "width": 1.0,
          "height": 1.0
      }
  }
]"""
{% endhighlight %}

#### 1. Go for the gold
{% highlight scala %}
parse(setOfProducts).extract[List[Map[String, Any]]]
/*
** List(Map(name -> An ice sculpture, tags -> List(cold, ice), price -> 12.5, id -> 2, dimensions -> Map(length -> 7.0, width -> 12.0, height -> 9.5)), Map(id -> 3, name -> A blue mouse, price -> 25.5, dimensions -> Map(length -> 3.1, width -> 1.0, height -> 1.0)))
*/
{% endhighlight %}

#### 2. Extract a field from each object using a sequence comprehension
{% highlight scala %}
val jsonSetOfProducts = parse(setOfProducts)

val names = for {
  JArray(products) <- jsonSetOfProducts
  JObject(product) <- products
  JField("name", JString(name)) <- product
} yield name
/*
**  List(An ice sculpture, A blue mouse)
*/
{% endhighlight %}

[*more examples in this style*](https://github.com/json4s/json4s/blob/3.6/tests/src/test/scala/org/json4s/JsonQueryExamples.scala)


#### 3. Extract using case classes

Again this is the preferred method.  Leverage one of Scala's best features, the case class, and own that JSON!

{% highlight scala %}
val jsonSetOfProducts = parse(setOfProducts)

case class ProductName(name: String)
val names = jsonSetOfProducts.extract[List[ProductName]]
/*
**  List(ProductName(An ice sculpture), ProductName(A blue mouse))
*/

case class ProductDimensions(dimensions: Map[String, Double])
val dimes = jsonSetOfProducts.extract[List[ProductDimensions]]
/*
**  List(ProductDimensions(Map(length -> 7.0, width -> 12.0, height -> 9.5)), ProductDimensions(Map(length -> 3.1, width -> 1.0, height -> 1.0)))
*/
{% endhighlight %}


#### 4. Transform, Find, Filter, RemoveField

{% highlight scala %}

jsonSetOfProducts transformField {
  case JField("name", JString(s)) => ("NAME", JString(s.toUpperCase))
}
/*
**  JArray(List(JObject(List((id,JInt(2)), (NAME,JString(AN ICE SCULPTURE)), (price,JDouble(12.5)), (tags,JArray(List(JString(cold), JString(ice)))), (dimensions,JObject(List((length,JDouble(7.0)), (width,JDouble(12.0)), (height,JDouble(9.5))))))), JObject(List((id,JInt(3)), (NAME,JString(A BLUE MOUSE)), (price,JDouble(25.5)), (dimensions,JObject(List((length,JDouble(3.1)), (width,JDouble(1.0)), (height,JDouble(1.0)))))))))
*/

jsonSetOfProducts filterField {
  case JField("name", _) => true
  case _ => false
}
/*
** List((name,JString(An ice sculpture)), (name,JString(A blue mouse)))
*/

jsonSetOfProducts findField {
  case JField("name", _) => true
  case _ => false
}
/*
**  Some((name,JString(An ice sculpture)))
*/

jsonSetOfProducts removeField {
  case JField("dimensions", _) => true
  case _ => false
}
/*
**  JArray(List(JObject(List((id,JInt(2)), (name,JString(An ice sculpture)), (price,JDouble(12.5)), (tags,JArray(List(JString(cold), JString(ice)))))), JObject(List((id,JInt(3)), (name,JString(A blue mouse)), (price,JDouble(25.5))))))
*/
{% endhighlight %}
