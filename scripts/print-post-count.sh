#!/bin/bash

for dir in _posts/*; do
  postCount=$(ls $dir | wc -l)
  pathPrintName=$(echo $dir | tr -d "_posts/")

  echo "week $pathPrintName: $postCount"
done
