#!/bin/bash

NESSUSD_MESSAGES=/var/vcap/store/nessus-manager/opt/nessus/var/nessus/logs/nessusd.messages
#check nessus license
NESSUS_LICENSE=`grep -A1 'nessusd-reloader: started' ${NESSUSD_MESSAGES} | tail -n -1 | grep 'Could not validate the license used on this scanner' | wc -l`

#check plugin age
PLUGIN_AGE=$(grep 'Nessus is reloading: Plugin auto-update' ${NESSUSD_MESSAGES} | tail -n 1| awk -F '[\[\]]' '{print $2}' | { read datefmt ; echo $(( ($(date +%s) - $(date -d "${datefmt}" +%s)) / 86400 )) ; })

#emit metrics
tempfile=`mktemp`
cat <<EOF > ${tempfile}
# HELP nessus_manager_license_invalid Nessus manager license status
# TYPE nessus_manager_license_invalid gauge
nessus_manager_license_invalid ${NESSUS_LICENSE}
# HELP nessus_manager_plugin_age Nessus manager plugin age
# TYPE nessus_manager_plugin_age gauge
nessus_manager_plugin_age ${PLUGIN_AGE}
EOF
mv ${tempfile} /var/vcap/jobs/node_exporter/config/nessus.prom
