#!/bin/bash

set -eux

export PATH=$PATH:/var/vcap/packages/jq-1.5/bin

rm -f /var/vcap/sys/log/nessus-manager/scans.log
rm -f /var/vcap/sys/log/nessus-manager/hosts.log

token=$(curl -sk -X POST \
  https://127.0.0.1:8834/session \
  -H 'Content-Type: application/json' \
  -d @<(cat <<EOF
{
  "username": "<%= p("nessus-manager.username") %>",
  "password": "<%= p("nessus-manager.password") %>"
}
EOF
) | jq -r ".token")

for scanid in $(curl -sk https://127.0.0.1:8834/scans \
    -H "X-Cookie: token=${token}" \
    | jq -r ".scans[] | .id"); do
  scan=$(curl -sk "https://127.0.0.1:8834/scans/${scanid}" \
    -H "X-Cookie: token=${token}")
  echo "${scan}" | jq -rc "del(.. | .history?) | del(.. | .plugin_set?)" >> /var/vcap/sys/log/nessus-manager/scans.log
  echo >> /var/vcap/sys/log/nessus-manager/scans.log
  for host in $(echo "${scan}" | jq -r ".hosts[] | .host_id"); do
    curl -sk "https://127.0.0.1:8834/scans/${scanid}/hosts/${host}" \
      -H "X-Cookie: token=${token}" \
      >> /var/vcap/sys/log/nessus-manager/hosts.log
    echo >> /var/vcap/sys/log/nessus-manager/hosts.log
  done
done
