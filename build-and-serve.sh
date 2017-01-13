#!/bin/bash

bundle exec jekyll serve > /dev/null &
sleep 2
open -a /Applications/Google\ Chrome.app http://localhost:4000/
