# Cloudflare Dynamic DNS Update Service

- POSIX-compliant
- Cloudflare API v4
- Bearer authentication
- DNS proxy recognition
- Installed as a cron job
- Compatible with OpenBSD

## Usage

```console
$ ./install.sh
```

## Requirement

- `curl`
- `jq`

## Design Consideration

No Python. Python 3.10 drops support for LibreSSL, thus not working on OpenBSD.
