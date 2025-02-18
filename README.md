# Cloudflare Dynamic DNS Update Service

Most existing Cloudflare DDNS scripts:
1. Use Python for network access (libressl complication on OpenBSD)
2. Need to config each domain individually in the zone
3. May not handle domain properties such as *proxied*/*non-proxied*

## Design

- Update all domains, *proxied* and *non-proxied*, in a given zone
- Track IP update fast (every minute) without authenticated Cloudflare API
- Keep it simple (no Python, no bash) to run on BSD
- Be comprehensive regarding error handling and logging

How to fast track IP update?

This script is designed to be run as cron job every minute. To minimize
authenticated connections to Cloudflare, it has an argument `sentinel_domain`,
which is any *non-proxied* domain in the given zone. `sentinel_domain` resolves
to the public IP directly (monitored publically with `dig`). If it is different
from the current public IP, then the script connects to Cloudflare to update
the DNS records.

Why comprehensive?

The big drawback of shell scripting is unenforced error handling, especially
compared to pure functional languages such as Haskell. This could lead to tons
of unexpected behaviors in long-term real-world deployments. We need
comprehensive error handling and logging here.

## Requirements

- `dig`
- `curl`
- `jq`

## Install

1. Create `/etc/ddns/cloudflare.keys` with contents:

```
ZONE_ID=xxxxxx
API_TOKEN=xxxxxx
```

2. Set the file `/etc/ddns/cloudflare.keys` to be only readable by the ddns service executor

3. Copy `ddns` to a directory of your choice, e.g., `/usr/local/bin/`

4. Add a cron job using `crontab -e` under the service executor/user:

```
* * * * * /usr/local/bin/ddns /etc/ddns/cloudflare.keys sentinel.domain 2>&1 | /usr/bin/logger -t ddns
```
