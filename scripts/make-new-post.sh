#!/bin/bash

source scripts/make-post-header.sh

[[ $# -ne 1 ]] && { echo "Must supply name of post as string passed to script" >&2; exit 1; }

postDate=$(date +%Y-%m-%d)
currentWeekNumber=$(date +%V)
postTopic="$1"
fileName=$postDate

for word in $postTopic; do
  fileName=$fileName-$word
done

fileName=$fileName.md
fileLocation=_posts/${currentWeekNumber}

[[ ! -d $fileLocation ]] && { mkdir $fileLocation; }

[[ -e $fileLocation/$fileName ]] &&  { echo "Error: File already exists $fileLocation/$fileName" >&2; exit 1; }

echo "Creating '$fileName' and inserting Jekyll header..."
header=$(makePostHeader "$postTopic")

echo "$header" >> $fileLocation/${fileName}

echo -e "\n...done."

exit 0
