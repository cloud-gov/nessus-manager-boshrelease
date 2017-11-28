#!/bin/bash

NESSUS_LICENSE=`grep -A1 'nessusd-reloader: started' /var/vcap/store/nessus-manager/opt/nessus/var/nessus/logs/nessusd.messages | tail -n -1 | grep 'Could not validate the license used on this scanner' | wc -l`

if [ ${NESSUS_LICENSE} -eq 1 ]; then
  /var/vcap/jobs/riemannc/bin/riemannc --host `hostname` --service nessus-manager.license --metric_sint64 ${NESSUS_LICENSE} --state "critical"
else
  /var/vcap/jobs/riemannc/bin/riemannc --host `hostname` --service nessus-manager.license --metric_sint64 ${NESSUS_LICENSE} --state "ok"
fi

tempfile=`mktemp`
cat <<EOF > ${tempfile}
# HELP nessus_manager_license_invalid Nessus manager license status
# TYPE nessus_manager_license_invalid gauge
nessus_manager_license_invalid ${NESSUS_LICENSE}
EOF
mv ${tempfile} /var/vcap/jobs/node_exporter/config/nessus.prom
