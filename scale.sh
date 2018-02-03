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

#oc get pods
#NAME                 READY     STATUS    RESTARTS   AGE
#broker-amq-1-clddb   1/1       Running   0          2d
# sed '1d', remove header, head -n 1, only process first line, save pod id to OPENSHIF_AMQ_BROKER_POD_ORIGINAL
#
#
#
echo "	--> Attempting to locate original pod"
OPENSHIFT_AMQ_BROKER_POD_ORIGINAL=`oc get pods | sed '1d' | head -n 1 | awk '{printf $1}'`
! [ $? == 0 ] && echo "FAILED" && exit 1
#
#
#
echo "	--> Find the replication controller which is in the deployment config"
OPENSHIFT_DEPLOYMENT_CONFIG=`oc get dc -l app=fuse-amq | sed '1d' | awk '$2>0 { print $1 }'`
! [ $? == 0 ] && echo "FAILED" && exit 1
#
#
#
echo "		--> Found ${OPENSHIFT_DEPLOYMENT_CONFIG}"
echo "	--> Scaling application to $SCALE_TO instances"
oc scale deploymentconfig ${OPENSHIFT_DEPLOYMENT_CONFIG} --replicas=$SCALE_TO 

echo "Done"
