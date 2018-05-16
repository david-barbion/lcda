#!/bin/bash

MC_LIST="Le crochet d'argent newsletter"


while [ ! -z "$1" ]; do
  case $1 in
    --url) shift; URL=$1;;
  esac
  shift
done

if [ -z "$URL" ]; then
  echo "missing --url URL" >&2
  exit 1
fi

######### 1 - get text #######################
echo "1. get html page"
curl -sL "$URL" |html2text -utf8 >/tmp/article.$$
vim /tmp/article.$$

######### 2 - get article title ##############
echo "2. get article title"
ART_TITLE=$(curl -sL "$URL" |sed '/<title>/!d;s/.*<title>\s*\(.*\)\s*<\/title>.*/\1/')
ART_SUBJECT="New article: $ART_TITLE"

######### 3 - get featured image #############
echo "3. get featured image"
# get post name
post_name=$(echo "${URL}" |sed 's#^.*/\([^/]*\)/#\1#')
# first get asset image path
asset_path="../assets/resized/${post_name}"
ART_FEATURED_IMAGE=$(ls "${asset_path}/featured-800"*)

echo "================ recap ===================="
echo "Subject: $ART_SUBJECT"
echo "Title: $ART_TITLE"
echo "Image: $ART_FEATURED_IMAGE"

read -p "Ok to create? (y/n) " ANSWER

if [ "$ANSWER" = "y" ]; then
  ./chimper-en.rb -l "$MC_LIST" -t "$ART_TITLE" -s "$ART_SUBJECT" -f "$ART_FEATURED_IMAGE" --template new-en --message-file /tmp/article.$$ --link "$URL"
fi
