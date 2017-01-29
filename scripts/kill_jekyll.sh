#!/bin/bash
echo "goodnight, sweet Jekyll..."

ps aux | grep jekyll | grep -v grep | cut -d' ' -f2 | xargs kill -9
