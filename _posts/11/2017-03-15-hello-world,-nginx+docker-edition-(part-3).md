---
layout: post
title:  "hello world, nginx+docker edition (part 3)"
date:   2017-03-15 22:01:08
categories: ops
excerpt: "continuing the nginx+docker series with basic authentication"
tags:
  - nginx
  - docker
---

I had a lot of fun with the previous Nginx/Docker posts so I thought I'd do it again.  [Here's a github repo which will track this project](https://github.com/lombardo-chcg/nginx-docker)

--

I found out it is possible to add basic HTTP authentication to an Nginx server [right in the config](http://nginx.org/en/docs/http/ngx_http_auth_basic_module.html).

In our `nginx.conf` file let's enable the `ngx_http_auth_basic_module` right under the server block:

{% highlight lua %}
...
  server {
    auth_basic "Protected Server";
    auth_basic_user_file /src/passwords;
...  
{% endhighlight %}

Note there's a reference to a `auth_basic_user_file` and we supply the path `/src/passwords`.

So let's create that file and add a username/password combo so Nginx can authenticate our users.

Nginx doesn't allow plain text passwords so we have to encrypt.  We will use the `openssl` library and set up our password as `LetMeIn` with username `superuser`.

Then we write that combo to the `/src/passwords` file, separated by a colon.

{% highlight bash %}
password=$(openssl passwd -crypt LetMeIn)
echo "superuser:$password" > src/passwords
{% endhighlight %}

Perfect.  Now when we run `docker-compose up --build` and visit `http://localhost/` in the browser we will be prompted to login.
