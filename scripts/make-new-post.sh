#!/bin/bash

source scripts/make-post-header.sh

while getopts "t:e" opt; do
	case $opt in
		t)
			postTopic="${OPTARG}"
			;;
		e)
			openEditor="true"
			;;
		\?)
			exit 1
			;;
	esac
done

[[ ! $postTopic ]] && { echo "Must supply '-t' flag with a post title" >&2; exit 1; }


# TODO seperate this make file logic into a function
postDate=$(date +%Y-%m-%d)
currentWeekNumber=$(date +%V)
fileName=$postDate

for word in $postTopic; do
  fileName=$fileName-$word
done

fileName=$fileName.md
fileLocation=_posts/${currentWeekNumber}

[[ ! -d $fileLocation ]] && { mkdir $fileLocation; }

[[ -e $fileLocation/$fileName ]] &&  { echo "Error: File already exists $fileLocation/$fileName" >&2; exit 1; }

echo "Creating '$fileLocation/$fileName' and inserting Jekyll header..."
  header=$(makePostHeader "$postTopic")

  echo "$header" >> $fileLocation/${fileName}
echo -e "\n...done."


if [[ $openEditor ]]; then
	echo -e "\nopening file..."
# TODO allow editor name to be passed in, if not, use system default $EDITOR or vi
# [[ $editorName ]] && { $editorName "$fileLocation/$fileName"; return; }

  vi "$fileLocation/$fileName"
fi

exit 0
