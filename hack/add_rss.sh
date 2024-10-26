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

# 获取 docs 下所有的xml文件
for file in $(ls $SCRIPT_PATH/../docs/*.xml); do
  python $SCRIPT_PATH/update_rss.py ${file} "$link" "$title"
done

cd $SCRIPT_PATH/../
git add .
git commit -m "Add new article: $title"
git push
