#!/bin/bash
echo "goodnight, sweet Jekyll..."

ps aux | grep jekyll | grep -v grep | awk  '{print $2}' | xargs kill -9
# alt: lsof -i TCP:4000 -sTCP:LISTEN | awk 'FNR==2 {print $2}' | xargs kill -9
