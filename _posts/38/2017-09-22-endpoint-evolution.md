---
layout: post
title:  "endpoint evolution"
date:   2017-09-22 07:20:29
categories: application-design
excerpt: "using content negotiation to avoid breaking changes in a Spring web service"
tags:
  - spring
  - java
  - jvm
  - api
  - http
---

* Given I have an existing web service application with consumers
* And I have a request to modify/update an endpoint to return new content
* Then I have an obligation to my existing consumers to not break their contract
* And still provide the new content

There's a few ways to do this.  Once common pattern is thru versioning in the resource path:

{% highlight bash %}
/v1/readings
/v2/readings
{% endhighlight %}

I think a more elegant and effective way to do this is thru Content Negotiation.

This is where I provision an endpoint to return content based on what the user requests, while providing a default case.

Here's an example of this pattern using [Spring Boot](https://start.spring.io/):

In this endpoint we have two `@RequestMapping`s to the same root path.

The top one is our initial endpoint.  It returns a simple list of Doubles.   

The v2 version is a breaking change - it returns a list of `SensorReading` instances.  Any consumers expecting a list of Doubles would be broken.

Lucky, by specifying the type of content our endpoint produces, Spring is able to help us out and return what the consumers requests via the standard HTTP `Accept` header, defaulting to the initial endpoint.

{% highlight java %}
@Controller
@EnableAutoConfiguration
public class SampleController {

    @RequestMapping("/")
    @ResponseBody
    ArrayList<Double> home() {
        {% raw %}return new ArrayList<Double>() {{{% endraw %} //"double brace initialization"
            add(55.4);
            add(66.5);
            add(102.5);
        {% raw %}}};{% endraw %}
    }

    @RequestMapping(path = "/", produces = "application/vnd.sampleApp.v2+json")
    @ResponseBody
    ArrayList<SensorReading> homeV2() {
        {% raw %}return new ArrayList<SensorReading>() {{{% endraw %}
            add(new SensorReading("8a8254d763f2", 32.6));
            add(new SensorReading("7c88da832f15", 35.50));
            add(new SensorReading("1120b2767b94", 45.30));
        {% raw %}}};{% endraw %}
    }
}
{% endhighlight %}


Usage:

{% highlight bash %}
curl -s localhost:8080 | jq
# [
#  55.4,
#  66.5,
#  102.5
# ]

curl -H "Accept: application/vnd.sampleApp.v2+json" localhost:8080 | jq
# [
#   {
#     "id": "8a8254d763f2",
#     "value": 32.6
#   },
#   {
#     "id": "7c88da832f15",
#     "value": 35.5
#   },
#   {
#     "id": "1120b2767b94",
#     "value": 45.3
#   }
# ]
{% endhighlight %}

Same endpoint, different content, no breaking changes.  Ship it!
