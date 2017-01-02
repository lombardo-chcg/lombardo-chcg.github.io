#!/bin/bash -x

function makePostHeader() {
  [[ $# -ne 1 ]] && { echo "makePostHeader: Must supply name of post as string passed to script" >&2; exit 1; }

  postTitle="$1"
  postDate=$(date +"%D %T")

  echo -e "---
layout: post
title:  \"$postTitle\"
date:   $postDate
categories:
tags:

---"

}
