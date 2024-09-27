#!/bin/bash

link=$1
title=$2

if [ -z "$link" ] || [ -z "$title" ]; then
  link=$(gum input --prompt "Enter the link: ")
  suggest_title=$(curl -sL $link | xmllint --html --xpath "//title/text()" - 2>/dev/null)
  title=$(gum input --prompt "Enter the title: " --value="$suggest_title")
fi

# 获取脚本的绝对路径
SCRIPT_PATH=$(cd $(dirname $0); pwd)
FEED_FILE=$SCRIPT_PATH/../docs/feed.xml

python $SCRIPT_PATH/update_rss.py "$FEED_FILE" "$link" "$title"

yq -p=xml -o=xml '
.rss.channel.follow_challenge = {
  "feedId": "62080294672416768",
  "userId": "59875101284335616"
}
' $FEED_FILE > temp.xml && mv temp.xml $FEED_FILE

cd $SCRIPT_PATH/../
git add $FEED_FILE
git commit -m "Add new article: $title"
git push
