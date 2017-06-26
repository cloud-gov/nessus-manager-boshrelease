#!/bin/bash

NESSUS_LICENSE=`grep -A1 'nessusd-reloader: started' /var/vcap/store/nessus-manager/opt/nessus/var/nessus/logs/nessusd.messages | tail -n -1 | grep 'Could not validate the license used on this scanner' | wc -l`

if [ ${NESSUS_LICENSE} -eq 1 ]; then
  /var/vcap/jobs/riemannc/bin/riemannc --host `hostname` --service nessus-manager.license --metric_sint64 ${NESSUS_LICENSE} --state "critical" --ttl 600
else
  /var/vcap/jobs/riemannc/bin/riemannc --host `hostname` --service nessus-manager.license --metric_sint64 ${NESSUS_LICENSE} --state "ok" --ttl 600
fi
