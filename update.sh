#!/bin/bash
echo 'Checking for urllist update...'
cd /app/symtg/
git pull
if ! cmp -s /app/urllist.txt.enc /app/symtg/urllist.txt.enc ; then
  echo 'Found newer encrypted urllist, updating...'
  echo 'Old file contain '"$(cat /app/urllist.txt | wc -l)"' urls'
  rm /app/urllist.txt.enc
  cp /app/symtg/urllist.txt.enc /app/urllist.txt.enc
  openssl enc -aes-256-cbc -d -md md5 -pass env:TG_PASSWORD -in /app/urllist.txt.enc -out /app/urllist.txt
  echo "$(cat /app/urllist.txt | wc -l)"' urls loaded in updated file'
fi
