#!/bin/bash

count=0
numPossible=0
numRegEx='^[0-9]+$'

echo "printing post count per week for year 2017"

for dir in _posts/*; do
  if [[ $(echo $dir | tr -d '_posts/') =~ $numRegEx ]] ; then
    postCount=$(ls $dir | wc -l)
    pathPrintName=$(echo $dir | tr -d "_posts/")
    noColor='\033[0m'

    let count=count+postCount
    let numPossible=numPossible+5

    [[ postCount -lt 5 ]] && outputColor='\033[0;31m' || outputColor='\033[0;32m'

    echo -e "${outputColor}week $pathPrintName: $postCount${noColor}"
  fi
done

echo -e "\n\033[0;32mtotal 2017 posts: $count ($numPossible possible)\n"
