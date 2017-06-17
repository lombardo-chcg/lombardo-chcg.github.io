#!/bin/bash

count=0
numPossible=0

for dir in _posts/*; do
  postCount=$(ls $dir | wc -l)
  pathPrintName=$(echo $dir | tr -d "_posts/")
  noColor='\033[0m'

  let count=count+postCount
  let numPossible=numPossible+5

  [[ postCount -lt 5 ]] && outputColor='\033[0;31m' || outputColor='\033[0;32m'

  echo -e "${outputColor}week $pathPrintName: $postCount${noColor}"
done

echo -e "\n\033[0;32mtotal posts: $count ($numPossible possible)\n"
