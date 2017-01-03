#!/bin/bash

source scripts/make-post-header.sh

[[ $# -ne 1 ]] && { echo "Must supply name of post as string passed to script" >&2; exit 1; }

postDate=$(date +%Y-%m-%d)
postTopic="$1"
fileName=$postDate

for word in $postTopic; do
  fileName=$fileName-$word
done

fileName=$fileName.md

[[ -e _posts/$fileName ]] &&  { echo "Error: File already exists _posts/$fileName" >&2; exit 1; }

echo "Creating '$fileName' and inserting Jekyll header..."
header=$(makePostHeader "$postTopic")

touch _posts/${fileName}
echo "$header" >> _posts/${fileName}

echo -e "\n...done."

exit 0
