---
layout: post
title:  "merge-base"
date:   2017-09-06 18:21:51
categories: git
excerpt: "using git merge-base to squash commits and create a clean project history"
tags:
  - git
  - gitflow
  - squash
  - rebase
  - merge
  - feature
---

A common pattern in software development is working off of a "feature branch", where a developer or a team forks off of the master branch of a repo, does a bunch of work (creating a bunch of commits), then needing to merge their code with master, and squash all the "work-in-progress" commit messages.

The `git-merge-base` is a fantastic way to solve this problem.  From the [docs](https://git-scm.com/docs/git-merge-base):

> git merge-base finds best common ancestor(s) between two commits

Let's walk thru it on a sample project.  Here are some commands to illustrate how it works:

{% highlight bash %}
mkdir git-merge-base-example && cd git-merge-base-example
git init
echo "hello world" >> 1.txt
git add .
git commit -m 'initial commit'
git checkout -b my-feature-branch
touch make-commits.sh && chmod a+x make-commits.sh
{% endhighlight %}

Now we have our "master" and "feature" branches set up.  So lets fill in that `make-commits.sh` script to simulate a developer workflow on this feature branch.

{% highlight bash %}
#!/bin/bash

for i in $(seq 0 10); do
  echo "hey $i" >> $i.txt
  git add .
  git commit -m "commit $i"
done
{% endhighlight %}

Now we can execute the script and perform the merge:

{% highlight bash %}
./make-commits.sh

# view the WIP commits we just made
git log

# see the merge-base magic
git merge-base master my-feature-branch
{% endhighlight %}

The output of `git merge-base` is the hash for the common ancestor commit between the two branches; in this case, the initial commit.  Now we can "reset" our working branch to that commit, which put all our new files in the `Untracked` bucket.  Then we simply create a new, single commit that contains all our changes, and merge back to the master branch.

{% highlight bash %}
git reset $(git merge-base master my-feature-branch)
# all our new files are present but `Untracked`
git add .
git commit -m 'complete my feature'

git checkout master
git merge my-feature-branch

git log
{% endhighlight %}

Now we see that we only have 2 commits, keeping our project history nice and clean.  
