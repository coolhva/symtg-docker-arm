FROM arm32v7/debian:stable

WORKDIR /app

COPY qemu-arm-static /usr/bin

RUN apt-get update; apt-get install -y --no-install-recommends curl git openssl cron ca-certificates

COPY urllist.txt.enc /app
COPY wss.sh /app
COPY startup.sh /app
COPY motd.txt /app
COPY update.sh /app

CMD ["/bin/bash", "/app/startup.sh"]
