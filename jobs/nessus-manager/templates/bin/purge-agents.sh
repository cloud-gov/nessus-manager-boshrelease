#!/bin/bash

set -e

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

# iterate through all our agents and unlink them
for sid in $(napi /scanners | ${JQ} .scanners[].id); do
    for aid in $(napi /scanners/${sid}/agents | ${JQ} -r .agents[].id); do
        napi /scanners/${sid}/agents/${aid} DELETE
    done
done
