#!/usr/bin/env sh

echo "Welcome to install the Cloudflare DDNS service."
echo -n "  Enter zone id: "
read ZONE_ID
echo -n "  Enter API token: "
read TOKEN

# GNU whereis is different from BSD whereis
WHERETEST=$(whereis sh | grep ":")
if [ -n "$WHERETEST" ]
then
    SH_PATH=$(whereis sh | awk '{print $2}')
else
    SH_PATH=$(whereis sh)
fi

echo "#!$SH_PATH" > ddns.sh
echo "" >> ddns.sh
echo "ZONE_ID=$ZONE_ID" >> ddns.sh
echo "CLOUDFLARE_API_TOKEN=$TOKEN" >> ddns.sh
cat payload.sh >> ddns.sh

SERVICE_PATH=$(realpath $(dirname $0))/ddns.sh

chmod 755 $SERVICE_PATH

echo "Install service as cron job..."
crontab -l | { cat; echo "*/10 * * * * $SERVICE_PATH"; } | crontab -

echo "Completed."
