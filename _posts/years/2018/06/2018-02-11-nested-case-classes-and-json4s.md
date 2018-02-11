---
layout: post
title:  "nested case classes and json4s"
date:   2018-02-11 08:46:28
categories: tools
excerpt: using json4s to extract case class instances that contain other case class instances in Scala
tags:
  - scala
  - json
  - json4s
  - serde
---

Description of the problem:
 - I have a Scala web service which accepts JSON from a UI.
 - The user input contains nested logical objects which I want to extract cleanly.  For example, I have a `User` data model, which in turn contains an `Address` data model.
 - I want to turn the incoming JSON directly into my target Scala data model but I am seeing errors like `org.json4s.package MappingException: No usable value ...`

Let's walk thru a solution.  Here's our Scala data model as discussed above:

{% highlight scala %}
case class Address(street: String, city: String, state: String, zip: String)

// User contains a nested Address instance
case class User(id: Long, name: String, email: String, address: Address)
{% endhighlight %}

The UI returns the following JSON to our Scala http server:

{% highlight json %}
{
  "id": 5407,
  "name": "Clementine Bauch",
  "email": "Sincere@april.biz",
  "address": {
    "street": "87473 Kulas Light",
    "city": "Gwenborough",
    "state": "CA",
    "zipcode": "92998"
  }
}
{% endhighlight %}

in our Scala app, we have brought in the following [json4s](https://github.com/json4s/json4s) dependencies (`build.gradle` format):

{% highlight groovy %}
dependencies {
  compile "org.json4s:json4s-ext_2.12:3.5.0"
  compile "org.json4s:json4s-jackson_2.12:3.5.0"
  compile "org.json4s:json4s-native_2.12:3.5.0"
}
{% endhighlight %}


OK!  Let's try to parse this JSON:
{% highlight scala %}

case class Address(street: String, city: String, state: String, zip: String)
case class User(id: Long, name: String, email: String, address: Address)
implicit val formats = org.json4s.DefaultFormats

val jsonRequestString = s"""
     |{
     |  "id": 5407,
     |  "name": "Clementine Bauch",
     |  "email": "Sincere@april.biz",
     |  "address": {
     |    "street": "87473 Kulas Light",
     |    "city": "Gwenborough",
     |    "state": "CA",
     |    "zip": "92998"
     |  }
     |}
   """.stripMargin

val parsedJson = parse(jsonRequestString)
val user = parsedJson.extract[User]

/*
* org.json4s.package$MappingException: No usable value for address
* No usable value for zip
* Did not find value which can be converted into java.lang.String
*/
{% endhighlight %}


What's happening here is that json4s does not know how to serialize or deserialize our nested case class.  The solution is to implement a `CustomSerializer` serdes.

details: [https://github.com/json4s/json4s#serializing-non-supported-types](https://github.com/json4s/json4s#serializing-non-supported-types)

It is pretty straightforward.  We need to supply an implementation for converting from a `JObject` to an `Address` instance, and then from an `Address` instance back to a `JObject`.  Here's how that looks:

{% highlight scala %}
import org.json4s.{CustomSerializer, JField, JObject, JString}

class AddressSerializer extends CustomSerializer[Address](format => (
  {
    case JObject(
      JField("street", JString(street))
      :: JField("city", JString(city))
      :: JField("state", JString(state))
      :: JField("zip", JString(zip))
      :: Nil
    ) => Address(street, city, state, zip)
  },
  {
    case address: Address =>
      JObject(
        JField("street", JString(address.street))
        :: JField("city", JString(address.city))
        :: JField("state", JString(address.state))
        :: JField("zip", JString(address.zip))
        :: Nil
      )
  }
))
{% endhighlight %}


Now we just need to update the implicit `Formats` which is in scope for the serdes work:

{% highlight scala %}
implicit val formats = org.json4s.DefaultFormats + new AddressSerializer

val user = parsedJson.extract[User]

/*
* User(5407L, "Clementine Bauch", "Sincere@april.biz", Address("87473 Kulas Light", "Gwenborough", "CA", "92998"))
*/
{% endhighlight %}

Now, we are able to work with Nested Case Classes and Json using json4s
