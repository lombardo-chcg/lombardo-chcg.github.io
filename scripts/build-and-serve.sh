#!/bin/bash

if [[ $1 == '--dev' ]];
  then bundle exec jekyll serve --limit_posts 1 > /dev/null &
  else bundle exec jekyll serve > /dev/null &
fi

echo "Starting Jekyll server on port 4000"
[[ $1 == '--dev' ]] && { echo "(dev mode enabled - single post only)"; }

waitExpression=1
count=0
timebox=30

checkJekyllServer() {
  [[ count -eq timebox ]] && { echo -e "\nJekyll failed to start (waited $timebox seconds)"; exit 1; }

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
