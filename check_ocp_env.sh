#!/bin/bash
echo " ------------------------------------"
echo " minishift status "
echo " ------------------------------------"
minishift status
echo " ------------------------------------"
echo " check amq image streams "
echo " ------------------------------------"
oc get is -n openshift | grep amq
echo " ------------------------------------"
echo " oc describe is jboss-amq-62 -n openshift"
echo " ------------------------------------"
oc describe is jboss-amq-62 -n openshift
echo " ------------------------------------"
echo " oc describe is jboss-amq-63 -n openshift"
echo " ------------------------------------"
oc describe is jboss-amq-63 -n openshift


