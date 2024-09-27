#!/bin/bash

# 获取脚本的绝对路径
SCRIPT_PATH=$(cd $(dirname $0); pwd)
FEED_FILE=$SCRIPT_PATH/../feed/feed.xml

python $SCRIPT_PATH/update_rss.py "$FEED_FILE" "$1" "$2"

yq -p=xml -o=xml '
.rss.channel.follow_challenge = {
  "feedId": "62080294672416768",
  "userId": "59875101284335616"
}
' $FEED_FILE > temp.xml && mv temp.xml $FEED_FILE

git add $FEED_FILE
git commit -m "Add new article: $2"
git push