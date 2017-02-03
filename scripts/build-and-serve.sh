#!/bin/bash

bundle exec jekyll serve > /dev/null &

waitExpression=1

checkJekyllServer() {
  curl -s localhost:4000/health | grep -q "<HEAD>"
  exitCode=$?
  [[ exitCode -eq 0 ]] && { waitExpression=0; }
}

until [[  $waitExpression -eq 0 ]]; do
  echo "."
  sleep 1
  checkJekyllServer
done

# on my linux box, open jekyll site in firefox
[[ $OSTYPE == "linux-gnu" ]] && { firefox http://localhost:4000/ 1>/dev/null 2>&1 & }

# on my mac, open in chrome
[[ $(uname) == "Darwin" ]] && { open -a /Applications/Google\ Chrome.app http://localhost:4000/; }
