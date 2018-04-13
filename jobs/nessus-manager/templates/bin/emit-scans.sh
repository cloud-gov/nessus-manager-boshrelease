#!/bin/bash

set -eux

export PATH=$PATH:/var/vcap/packages/jq-1.5/bin

EXPIRATION_DAYS="<%= p('nessus-manager.expiration-days') %>"

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

# Emit scans and host vulnerabilities to logs
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

# Delete old scan history
for scanid in $(curl -sk https://127.0.0.1:8834/scans \
    -H "X-Cookie: token=${token}" \
    | jq -r ".scans[] | .id"); do
  for historyid in $(curl -sk "https://127.0.0.1:8834/scans/${scanid}" \
      -H "X-Cookie: token=${token}" \
      | jq -r --arg timestamp $(date --date "-${EXPIRATION_DAYS} days" +%s) \
        ".history | select(.creation_date < (\$timestamp | tonumber)) | .history_id"); do
    curl -sk -X DELETE \
      "https://127.0.0.1:8834/scans/${scanid}/history/${historyid}" \
      -H "X-Cookie: token=${token}"
  done
done

# if we reached here, then we didn't bomb out in some way because the API
# changed or something, so let's log that success so that we can alert if
# this gets old.
cat <<EOF > /var/vcap/jobs/node_exporter/config/nessusscandelete.prom
# HELP nessus_manager_scandelete_time When emit-scans.sh on Nessus Manager successfully deleted scans
# TYPE nessus_manager_scandelete_time gauge
nessus_manager_scandelete_time $(date +%s)
EOF
