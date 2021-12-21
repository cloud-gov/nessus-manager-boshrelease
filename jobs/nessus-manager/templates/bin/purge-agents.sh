#!/bin/bash

# our version of nessus-manager does a poor job of maintaining 
# agents on ephemeral nodes. As a work around 
# * first unlink all agents, (./purge-agents.sh unlink)
# * wait for them relink if they're active (e.g at :30)
# * delete agents that haven't relinked (./purge-agents.sh delete)
# * hope they then register and link 

set -e
case $1 in 
  unlink) ACTION=unlink;;
  delete) ACTION=delete;;
  *) echo "Usage: $0 unlink|delete"
     exit 1;;
esac

# where is jq?
JQ=/var/vcap/packages/jq-1.5/bin/jq

# where is nessus?
NESSUS_URL=https://localhost:8834


# authenticate and grab the token
TOKEN=$(curl -s -k -X POST -H 'Content-Type: application/json' -d '{"username":"<%= p("nessus-manager.username") %>","password":"<%= p("nessus-manager.password") %>"}' ${NESSUS_URL}/session | ${JQ} -r .token)

# make a curl request to the nessus api using token based auth
napi() {
    if [ ! -z "${2}" ]; then
        METHOD="-X ${2}"
    else
        METHOD="-X GET"
    fi

    # yes nessus uses it's own special header called X-Cookie :/
    curl -s -k ${METHOD} -H "X-Cookie: token=${TOKEN};" ${NESSUS_URL}${1}
}

# iterate through all our agents and unlink or delete them
for sid in $(napi /scanners | ${JQ} .scanners[].id); do
    for aid in $(napi /scanners/${sid}/agents | ${JQ} -r .agents[].id); do
        case $ACTION in
          unlink) 
            napi /scanners/${sid}/agents/${aid} DELETE;;
          delete) 
            napi /scanners/${sid}/agents/${aid} GET | 
              $JQ '.status' | grep -q offline && napi /agents/${aid} DELETE;;
          *)
            echo "FAIL - invalid action: $ACTION"
            exit 1;;
       esac
    done
done
