#!/bin/bash

# Configuration

. ./config.sh

SCALE_TO=2

if [ $# -eq 0 ]; then
    echo "No argument supplied, scaling to " $SCALE_TO
else
   SCALE_TO=$1
   echo "Now scaling to " $SCALE_TO
fi
#
# sed '1d', remove header, tail -n 1, only process first line, save pod id to OPENSHIF_AMQ_BROKER_POD_ORIGINAL
#
echo "	--> Attempting to locate the stateful set"
OPENSHIFT_AMQ_BROKER_STATEFULSET=`oc get statefulset | tail -n 1 | awk '{ print $1 }'`
! [ $? == 0 ] && echo "FAILED" && exit 1
#
#
#
echo "		--> Found StatefulSet[ ${OPENSHIFT_AMQ_BROKER_STATEFULSET} ]"
echo "	--> Scaling application to $SCALE_TO instances"
oc scale statefulset ${OPENSHIFT_AMQ_BROKER_STATEFULSET} --replicas=$SCALE_TO 

echo "Done"
