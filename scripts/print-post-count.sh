#!/bin/bash

for dir in _posts/*; do
  postCount=$(ls $dir | wc -l)
  pathPrintName=$(echo $dir | tr -d "_posts/")
  noColor='\033[0m'

  [[ postCount -lt 5 ]] && outputColor='\033[0;31m' || outputColor='\033[0;32m'

  echo -e "${outputColor}week $pathPrintName: $postCount${noColor}"
done
