---
layout: post
title:  "file system permissions"
date:   2017-02-07 21:25:01
categories: environment
excerpt: "'it's a Unix system... I know this...'"
tags:
  - unix
  - chmod
---

When you run `ls -l` on a file directory you get some very useful information.  You are asking the system to list directory contents, in long format.
{% highlight bash %}
drwxr-xr-x   7 louie  staff   238B Feb  3 22:06 scripts
{% endhighlight %}

I'd like to focus on the first block of text which is 10 characters, `drwxr-xr-x`

the first character is a special character that describes the type of file.  A `-` indicates it is a regular file and `d` indicates it is a directory.  There are 5 other options which I won't discuss now but you can read about them via `man ls`.

The remaining 9 characters are broken into 3 sections and specify the file system permissions.  The three sections represent:

* Owner permissions
* Group permissions
* Everyone else's permissions

The order is `read status, write status, executable status`.  Think of it like this:
`owner | group | everyone else` with each section getting three characters.

`rw-rw-r--` indicates the file is readable and writeable but not executable for the Owner and Group, and only readable for everyone else.
`x` on a file means the file is executable (such as a shell script).  `x` on a directory means the directory is searchable.

To change any permissions just use the change mode command: `chmod a+r file_name` would give all users read access to a file.  `chmod` is a very intuitive interface.  It also has a `-R` option to walk a directory hierarchy and perform the requested action on every entry.

If you ever see a `403 forbidden` status on a http response, there could be a file permission issue with the resource you are trying to access.  The solution may be to add `r` status to the 3rd permissions group and that solved a problem for me today.
