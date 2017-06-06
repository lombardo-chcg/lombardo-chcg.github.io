#!/bin/bash

git add .
git commit -m "$(date +"%b %d") add script"
git push origin $(git branch | grep --color=never '*' | sed 's|* ||')
