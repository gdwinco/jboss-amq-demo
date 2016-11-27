#!/bin/bash 
# add -x to line above to debug
# requires bash 4.2 or later

export OPENSHIFT_RHSADEMO_USER_PASSWORD_DEFAULT=admin

echo $OPENSHIFT_RHSADEMO_USER_PASSWORD_DEFAULT 

if [[ ! -z OPENSHIFT_RHSADEMO_USER_PASSWORD_DEFUALT+1 ]] ; then
       echo " PASSWORD IS: ["$OPENSHIFT_RHSADEMO_USER_PASSWORD_DEFAULT"]"
fi

if [[ ! -z OPENSHIFT_RHSADEMO_USER_PASSWORD_DEFAULT ]] ; then
	echo "--> Using RHSADEMO password for openshift"
	OPENSHIFT_PRIMARY_USER_PASSWORD_DEFAULT=$OPENSHIFT_RHSADEMO_USER_PASSWORD_DEFAULT
else
	[[ ! -z OPENSHIFT_PRIMARY_USER_PASSWORD_DEFAULT ]] && echo "Please set OPENSHIFT_PRIMARY_USER_PASSWORD_DEFAULT to your openshift password" && exit 1
fi

OPENSHIFT_DOMAIN_DEFAULT=192.168.99.100:8443
OPENSHIFT_DOMAIN=${OPENSHIFT_DOMAIN_DEFAULT}

OPENSHIFT_PRIMARY_MASTER_DEFAULT=https://${OPENSHIFT_DOMAIN_DEFAULT}
OPENSHIFT_PRIMARY_MASTER=$OPENSHIFT_PRIMARY_MASTER_DEFAULT

OPENSHIFT_PRIMARY_APPS_DEFAULT=apps.${OPENSHIFT_DOMAIN_DEFAULT}
OPENSHIFT_PRIMARY_APPS=${OPENSHIFT_PRIMARY_APPS_DEFAULT}

# - change
OPENSHIFT_PRIMARY_USER_DEFAULT=admin
OPENSHIFT_PRIMARY_USER=${OPENSHIFT_PRIMARY_USER_DEFAULT}
OPENSHIFT_PRIMARY_USER_PASSWORD=${OPENSHIFT_PRIMARY_USER_PASSWORD_DEFAULT}
# - change
OPENSHIFT_PRIMARY_PROJECT_AMQ_DEFAULT=amq-demo-secure
OPENSHIFT_PRIMARY_PROJECT_DEFAULT=${OPENSHIFT_PRIMARY_PROJECT_AMQ_DEFAULT}
OPENSHIFT_PRIMARY_PROJECT=${OPENSHIFT_PRIMARY_PROJECT_DEFAULT}

OPENSHIFT_APPLICATION_NAME_AMQ_BROKER_DEFAULT=broker
OPENSHIFT_APPLICATION_NAME_DEFAULT=${OPENSHIFT_APPLICATION_NAME_AMQ_BROKER_DEFAULT}
OPENSHIFT_APPLICATION_NAME=${OPENSHIFT_APPLICATION_NAME_DEFAULT}

echo "Configuration_______________________________________________"
echo "OPENSHIFT_DOMAIN_DEFAULT                = ${OPENSHIFT_DOMAIN_DEFAULT}"
echo "OPENSHIFT_DOMAIN                        = ${OPENSHIFT_DOMAIN}"
echo "OPENSHIFT_PRIMARY_MASTER_DEFAULT        = ${OPENSHIFT_PRIMARY_MASTER_DEFAULT}"
echo "OPENSHIFT_PRIMARY_MASTER                = ${OPENSHIFT_PRIMARY_MASTER}"
echo "OPENSHIFT_PRIMARY_APPS_DEFAULT          = ${OPENSHIFT_PRIMARY_APPS_DEFAULT}"
echo "OPENSHIFT_PRIMARY_APPS                  = ${OPENSHIFT_PRIMARY_APPS}"
echo "OPENSHIFT_PRIMARY_USER_DEFAULT          = ${OPENSHIFT_PRIMARY_USER_DEFAULT}"
echo "OPENSHIFT_PRIMARY_USER                  = ${OPENSHIFT_PRIMARY_USER}"
echo "OPENSHIFT_PRIMARY_USER_PASSWORD_DEFAULT = `echo ${OPENSHIFT_PRIMARY_USER_PASSWORD_DEFAULT} | md5sum` (obfuscated)"
echo "OPENSHIFT_PRIMARY_USER_PASSWORD         = `echo ${OPENSHIFT_PRIMARY_USER_PASSWORD} | md5sum` (obfuscated)"
echo "OPENSHIFT_PRIMARY_PROJECT_AMQ_DEFAULT   = ${OPENSHIFT_PRIMARY_PROJECT_AMQ_DEFAULT}"
echo "OPENSHIFT_PRIMARY_PROJECT_DEFAULT       = ${OPENSHIFT_PRIMARY_PROJECT_DEFAULT}"
echo "OPENSHIFT_PRIMARY_PROJECT               = ${OPENSHIFT_PRIMARY_PROJECT}"
echo "OPENSHIFT_APPLICATION_NAME_AMQ_BROKER_DEFAULT = ${OPENSHIFT_APPLICATION_NAME_AMQ_BROKER_DEFAULT}"
echo "OPENSHIFT_APPLICATION_NAME_DEFAULT      = ${OPENSHIFT_APPLICATION_NAME_DEFAULT}"
echo "OPENSHIFT_APPLICATION_NAME              = ${OPENSHIFT_APPLICATION_NAME}"
echo "____________________________________________________________"


