#!/usr/bin/env bash
# Builds one AutoDNS.xex per resolver into the repo root. Attach them to a
# release; they are gitignored.
set -e
cd "$(dirname "$0")"
while read -r name dns1 dns2; do
    ./build.sh "$dns1" "$dns2" >/dev/null
    cp build/AutoDNS.xex "AutoDNS-$name.xex"
    echo "AutoDNS-$name.xex  ($dns1, $dns2)"
done <<'LIST'
cloudflare 1.1.1.1 1.0.0.1
google 8.8.8.8 8.8.4.4
quad9 9.9.9.9 149.112.112.112
opendns 208.67.222.222 208.67.220.220
LIST
