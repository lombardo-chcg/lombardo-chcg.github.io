---
layout: post
title:  "aws summit chicago report"
date:   2017-07-27 19:13:17
categories: conferences
excerpt: "brain dump after attending the 2017 aws summit at mccormick place chicago"
tags:
  - amazon
  - cloud
---

I attended Day 2 of the AWS Summit Chicago at McCormick Place's Lakeside Center.  

It was a great experience.  Super glad I went.

I have some experience with AWS, having deployed my [Scrabble Helper](/security/2017/07/10/knock-knock.html) project there.  My experience so far has left me feeling that to tooling and UX is extremely utilitarian but highly effective.

Today I got a better picture of what AWS is all about.  And I have to say I was pretty much blown away.  They have taken every imaginable piece of I/T infrastructure that can be "cloud-ified", and built a product around it.  And each product has clear value and vision.  Its really an amazing achievement.  And, AWS is now even going to the point where they are inventing new products that don't even represent anything that traditional I/T infrastructure brings to the table.

Here's a little brain dump of some stuff I learned today

**AWS Kinesis** is their answer to Kafka: real time data "streaming" based on a distributed log format
* as a reminder...Kinesis means "movement"
* AWS Kinesis is a fully managed service - the end user doesn't have to manage the instances
* Currently Netflix has over 100,000 Kinesis instances deployed in production
* Parts of AWS infrastructure (such as network flow logs) can be hooked into Kinesis with ZERO CODE
* the open source Kinesis Client Library (KCL) is also available.  Its purpose to to abstract away the process of connecting clients to the data stream, checkpointing, managing the clients relationships to the shards...basically, it handles the plumbing to connect client code to the data stream.

Some drawbacks of Kinesis:
* no log compaction
* data is only persisted for 7 days

If these are requirements, managing your own Kafka cluster is a better choice.  But if ephemeral streams are all that is needed, Kinesis is a super impressive product.

**AWS Redshift** is a SQL warehouse
* as a reminder...a red shift is when a star is moving away from an observer (like doppler, but for light)
* AWS Redshift is a massive cloud SQL database
* use case: Fortune 100 company has huge qty's of data (petabytes...) and needs to be able to run active queries against it.
* Uses "massively parallel processing" to achieve its efficiency
* users of Redshift interact with a "leader node" which implements a Postgres interface.  This means the standard SQL connection tools like JDBC can be used.  It's brilliant design.
* There is a schema conversion tool which can be used to analyze the structure of the data, and the even perform the transfer to Redshift.
* Redshift Spectrum allows users to query data that is stored in AWS S3 buckets (AWS Simple Storage Service)

**Apache Flink** is like Spark but "streaming first"
* Spark is known for batch processing, Flink does similar data processing but with streams
* It's a way to do mappings and transformations on data streams (such as Kinesis)

**AWS Cloudformation** is "infrastructure as code"
* declare resources using a JSON or YAML template, hit deploy, and watch them form
* reminded me of a Docker Compose
* here's an example infrastructure that can be composed with Cloudformation

{% highlight bash %}

EC2 instance  --> kinesis --> EMR (Elastic MapReduce)  ----
(Linux server)  (data stream)      Apache Flink           |
                                                          |
                                                          |
      another EC2 Instance    <-------------- ELK <--------
                                  (ElasticSearch + Kibana)
{% endhighlight %}

This is some massive infrastructure, and it can be deployed with a template.  It's amazing.

**Lambda@Edge**
* Lambda is basically a way to deploy small scripts and programs that run on AWS but don't require a tradition server to be deployed
* Deploy code without the server
* this is what I was talking about in the intro when I mentioned products that are new inventions, beyond the realm of traditional I/T
* Lambda@Edge allows for these "cloud programs" to be run on HTTP traffic before the traffic even reaches a server.  This functionality allows for code that makes decisions on requests in a super fast and highly customizable manner.  Sample uses include reading headers, rewriting URLS, serving custom content and validating sessions.

**EC2**
* the thing most people probably think of when thinking AWS
* A guest OS on a hypervisor
* naming scheme:

{% highlight bash %}
say your instance is a c4.large


  generation
   |
   |
  c4.large
  |   |
  |   |
  |   size
family  
{% endhighlight %}

As an employee at a "___ as a service" (software, platform, insights, analytics) company here in Chicago (Uptake), I know the challenges that come along with trying to deliver value in this manner.  I was totally impressed away by how Amazon has built cloud products around so many parts of software development infrastructure.  
