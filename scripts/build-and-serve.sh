#!/bin/bash

bundle exec jekyll serve > /dev/null &

echo "Starting Jekyll server on port 4000"

waitExpression=1
count=0

checkJekyllServer() {
  [[ count -eq 10 ]] && { echo -e "\nJekyll failed to start (waited 10 seconds)"; exit 1; }

  curl -s localhost:4000/health | grep -q "<HEAD>"
  exitCode=$?
  [[ $exitCode -eq 0 ]] && { waitExpression=0; }
}

until [[  $waitExpression -eq 0 ]]; do
  echo -n "."
  sleep 1
  checkJekyllServer
  let count=count+1
done

echo -e "\nServer Started (took $count seconds)"

# on my linux box, open jekyll site in firefox
[[ $OSTYPE == "linux-gnu" ]] && { firefox http://localhost:4000/ 1>/dev/null 2>&1 & }

# on my mac, open in chrome
[[ $(uname) == "Darwin" ]] && { open -a /Applications/Google\ Chrome.app http://localhost:4000/; }
