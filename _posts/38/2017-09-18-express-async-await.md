---
layout: post
title:  "express async await"
date:   2017-09-18 21:20:56
categories: languages
excerpt:  using javascript's async/await feature in a node http server
tags:
  - node
  - promise
  - js
  - ES2017
---

Here's a quick example of using the JavaScript/ES2017 `async/await` feature inside a Node Express app.  `async/await` is a way to force synchronous execution of asynchronous code.  One benefit: [avoiding promise pyramids of doom](https://gist.github.com/fariszacina/a79860e23bb9a6133936).

My use case is to gather a bunch of data together from separate api calls before doing some work and returning one result to the caller (especially if certain calls depend on data from previous calls before executing).

In our case, an axios request can fail, which is a rejected promise and needs to be caught, hence the `try / catch` you see below.  If I were working on a Express app long term I would probably work on a wrapper class similar to a Scala  `Either` or `Try` which would provide an abstraction over these potentially unsafe i/o operations.

But for now, the example.

*NOTE: this only works on newer versions of Node.  I am running 8.5.0 in this case*

{% highlight JavaScript %}
const express = require('express');
const axios = require('axios');

const app = express();

// async function returns a promise
async function makeServiceCall() {
  return axios.get('https://jsonplaceholder.typicode.com/posts');
}

async function makeOtherServiceCall() {
  return axios.get('https://jsonplaceholder.typicode.com/comments');
}

// IMPORTANT!  must declare the route's callback function as async
app.get('/', async function (req, res) {
  try {
    // 'await' expression blocks until the promise is resolved/rejected
    const apiData = await makeServiceCall();
    const otherApiData = await makeOtherServiceCall();

    const responseBody = {
      thing: apiData.data.length,
      otherThing: apiData.data.length
    }
    res.status(200).json(responseBody);
  } catch(e) {
    console.log(e.stack)
    res.status(500).send({error: e.message})
  }
});

app.listen(9000, function() {
  console.log('Server started on port 9000');
});
{% endhighlight %}
