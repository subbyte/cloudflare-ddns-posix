
IP=$(curl -s https://cloudflare.com/cdn-cgi/trace | grep -E '^ip' | cut -d '=' -f 2)

if [ -n "$IP" ]
then
    RECORDS_FILE=$(mktemp)
    curl --silent --request GET \
        --url "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
        --header "Content-Type: application/json" \
        --header "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -o $RECORDS_FILE

    if jq -r '.success' $RECORDS_FILE | grep -q true
    then
        RECORD_IDS=$(jq --arg IP $IP -r '.result[] | select(.content != $IP) | .id' $RECORDS_FILE)

        for RECORD_ID in $RECORD_IDS
        do
            DOMAIN_NAME=$(jq --arg ID $RECORD_ID -r '.result[] | select(.id == $ID) | .name' $RECORDS_FILE)
            PROXIED=$(jq --arg ID $RECORD_ID -r '.result[] | select(.id == $ID) | .proxied' $RECORDS_FILE)

            logger "DDNS: outdated IP detected at $DOMAIN_NAME"

            RESULT_FILE=$(mktemp)
            curl --silent --request PUT \
                --url https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID \
                --header "Content-Type: application/json" \
                --header "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
                --data "{\"type\":\"A\",\"name\":\"$DOMAIN_NAME\",\"content\":\"$IP\",\"proxied\":$PROXIED}" \
                -o $RESULT_FILE

            if jq -r '.success' $RESULT_FILE | grep -q true
            then
                logger "DDNS: DNS update successfully"
            else
                ERROR=$(jq -c '.errors' $RECORDS_FILE)
                logger "DDNS: DNS update failed: $ERROR"
            fi
            rm $RESULT_FILE
        done
    else
        ERROR=$(jq -c '.errors' $RECORDS_FILE)
        logger "DDNS: DNS access failed: $ERROR"
    fi
    rm $RECORDS_FILE
else
    logger "DDNS: network error, could not access cloudflare.com"
fi
