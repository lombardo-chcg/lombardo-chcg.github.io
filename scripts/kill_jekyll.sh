#!/bin/bash
echo "goodnight, sweet Jekyll..."

ps aux | grep jekyll | grep -v grep | awk  '{print $2}' | xargs kill -9
