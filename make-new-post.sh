#!/bin/bash

source scripts/make-post-header.sh

[[ $# -ne 1 ]] && { echo "Must supply name of post as string passed to script" >&2; exit 1; }

postDate=$(date +%Y-%m-%d)
currentMonth=$(date +%m)
postTopic="$1"
fileName=$postDate

for word in $postTopic; do
  fileName=$fileName-$word
done

fileName=$fileName.md
fileLocation=_posts/${currentMonth}

[[ -e $fileLocation/$fileName ]] &&  { echo "Error: File already exists $fileLocation/$fileName" >&2; exit 1; }

echo "Creating '$fileName' and inserting Jekyll header..."
header=$(makePostHeader "$postTopic")

echo "$header" >> _posts/${currentMonth}/${fileName}

echo -e "\n...done."

exit 0
