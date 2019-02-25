#!/bin/bash
# Generate a temporary filename to store a selection of urls
# and output. We do that because we can have the script
# running concurrent if the interval is low
tmpfile=/app/$(date "+%Y.%m.%d-%H.%M.%S").tmp
tmpoutfile=/app/$(date "+%Y.%m.%d-%H.%M.%S").out

# Check if today is a working day
if [[ $(date +%u) -lt 6 ]] ; then
  shuf /app/urllist.txt | head -$TG_URLS > $tmpfile
fi

# Check if today is a day in the weekend
if [[ $(date +%u) -gt 5 ]] ; then
  shuf /app/urllist.txt | head -$((($TG_WEEKEND*$TG_URLS)/100)) > $tmpfile
fi

# Loop through the urls in the file and visit them 
for i in $(cat $tmpfile)
do
# Visit the site with 10 second time out, accept any certificate with a Windows 10 Edge user agent
curl --silent --proxy $TG_PROXY --max-time 10 --insecure --location --user-agent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.246' --output $tmpoutfile $i
done

# Clean up
rm $tmpfile
rm $tmpoutfile
