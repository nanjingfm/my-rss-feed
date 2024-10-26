#!/bin/bash

feed_file=$1
user_id=$2
feed_id=$3

xmlstarlet ed -L \
  -s "/rss/channel" -t elem -n "follow_challenge" -v "" \
  -s "/rss/channel/follow_challenge" -t elem -n "feedId" -v "${feed_id}" \
  -s "/rss/channel/follow_challenge" -t elem -n "userId" -v "${user_id}" \
  "$feed_file"