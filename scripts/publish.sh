#!/bin/bash
commmitMsg=${1:-$(date +"%b %d")}

git add .
git commit -m "$commmitMsg"
git push origin $(git branch | grep --color=never '*' | sed 's|* ||')
