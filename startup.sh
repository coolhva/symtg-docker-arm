#!/bin/bash
# Display the ASCII banner
cat /app/motd.txt

# Get external ip address
TG_IP=$(curl --silent --user-agent "symtg 1.0" https://vanachterberg.org/ip/)

# Check if the password variable is set
if [ -z "$TG_PASSWORD" ]; then
  echo "Password not set, unable to decrypt urllist, exiting"
  exit 3
fi

# Check if the proxy variable is set, if not set the default
if [ -z "$TG_PROXY" ]; then
  echo "Proxy server (TG_PROXY) not set, using default of http://proxy.threatpulse.com:8080"
  export TG_PROXY="http://proxy.threatpulse.com:8080"
fi

# Check if the URL quantity variable is set, if not set the default
if [ -z "$TG_URLS" ]; then
  echo "URL quantity (TG_URLS) not set, using default of 1000"
  export TG_URLS="1000"
fi

# Check if the interval variable is set, if not set the default
if [ -z "$TG_INTERVAL" ]; then
  echo "Interval (TG_INTERVAL) not set, using default of 10 minutes"
  export TG_INTERVAL="10"
fi

# Check if the interval variable is set, if not set the default
if [ -z "$TG_WEEKEND" ]; then
  echo "Weekend percentage (TG_WEEKEND) not set, using 100% in the weekend"
  export TG_WEEKEND="100"
fi

# Decrypt the urllist with the supplied password
openssl enc -aes-256-cbc -d -md md5 -pass env:TG_PASSWORD -in /app/urllist.txt.enc -out /app/urllist.txt

# Check if the decryption command was succesful, if not exit and stop the container
if  [[ $? -ne 0 ]]; then
  echo "Invalid password, exiting"
  exit 4
fi

# Check if the git repo is already cloned
if [ ! -d "/app/symtg/.git" ]; then
  # clone git repo for updates
  echo 'Cloning urllist repo for updates (daily at 01:00)'
  git clone https://github.com/coolhva/symtg /app/symtg/
fi

# Updating the urllist
/app/update.sh

# load the amount of URLS
TG_URLSLOADED=$(cat /app/urllist.txt | wc -l)

# Add the wss script with the interval in the crontab file
echo '*/'"$TG_INTERVAL"' * * * * . /app/env.sh; /app/wss.sh' > /etc/cron.d/app

# Add the update script (runs daily at 01:00) to the crontab file
echo '0 1 * * * . /app/env/sh; /app/update.sh' >> /etc/cron.d/app

# Run crontab to add this to the crontab deamon
crontab /etc/cron.d/app

# Create sourcing script
echo '#!/bin/bash' > /app/env.sh
printenv | sed 's/^\(.*\)$/export \1/g' | grep -E "^export TG_" > /app/env.sh
chmod +x /app/env.sh

# Show settings
echo ''
echo 'Settings        : '
echo 'Version         : 1.2 arm'
echo 'Proxy           : '"$TG_PROXY"
echo 'Interval (min)  : '"$TG_INTERVAL"
echo 'Weekend         : '"$TG_WEEKEND"'%'
echo 'URLS quantity   : '"$TG_URLS"
echo 'URLS loaded     : '"$TG_URLSLOADED"
echo 'External IP     : '"$TG_IP"
echo ''
echo Starting crond...
# Start the cron daemon in foreground mode to keep the container running
cron -l 5 -f
