#!/bin/bash

git add .
git commit -m "$(date +"%b %d")"
git push origin $(git branch | grep --color=never '*' | sed 's|* ||')
