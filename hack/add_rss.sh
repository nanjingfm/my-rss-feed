#!/bin/bash

link=$1
title=$2

if [ -z "$link" ] || [ -z "$title" ]; then
  link=$(gum input --prompt "Enter the link: ")

  html=$(curl -sL $link)
  suggest_title=$(echo $html | pup 'meta[property="og:title"] attr{content}')
  title=$(gum input --prompt "Enter the title: " --value="$suggest_title")

  suggest_description=$(echo $html | pup 'meta[property="og:description"] attr{content}')
  description=$(gum input --prompt "Enter the description: " --value="$suggest_description")
fi

cat <<EOF
Parameters:

       url: $link
      title: $title
description: $description

EOF

if [ -z "$description" ]; then
  description=$title
fi

# 获取脚本的绝对路径
SCRIPT_PATH=$(cd $(dirname $0); pwd)
cd $SCRIPT_PATH/../
git stash
git pull --rebase
git stash pop

# 获取 docs 下所有的xml文件
for file in $(ls $SCRIPT_PATH/../docs/*.xml); do
  python $SCRIPT_PATH/update_rss.py ${file} "$link" "$title" "$description"
done

git add .
git commit -m "Add new article: $title"
git push
