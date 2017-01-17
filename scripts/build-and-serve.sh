#!/bin/bash

bundle exec jekyll serve > /dev/null &
# kill it:
# ps aux | grep jekyll
# kill -9 <jekyll_pid>

sleep 2

# on my linux box, open jekyll site in firefox
[[ $OSTYPE == "linux-gnu" ]] && { firefox http://localhost:4000/ 1>/dev/null 2>&1 & }

# on my mac, open in chrome
[[ $(uname) == "Darwin" ]] && { open -a /Applications/Google\ Chrome.app http://localhost:4000/; }
