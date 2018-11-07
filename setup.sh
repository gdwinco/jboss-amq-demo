#!/bin/bash

####
echo $'\n#################################################################'
echo "USAGE: setup.sh - run without cleaning up from previous runs
echo "USAGE: setup.sh clean - run invoking clean.sh first
echo $'#################################################################\n'
if [[ $# -eq 1 ]] ; then
  if [[ $1 = "clean" ]] ; then 
    . ./clean.sh 
  fi
fi

# Configuration
#. ./clean.sh
. ./config.sh

echo "	--> Create a keystore for the broker SERVER"
! [ -f amq-server.ks ] && keytool -genkeypair -keystore amq-server.ks -storepass password -keyalg RSA -alias amq-server -dname "CN=${OPENSHIFT_PRIMARY_USER}" -keypass password
! [ $? == 0 ] && echo "FAILED" && exit 1

echo "	--> Export the broker SERVER certificate from the keystore"
! [ -f amq-server_cert ] && keytool -export -alias amq-server -keystore amq-server.ks -storepass password -file amq-server_cert
! [ $? == 0 ] && echo "FAILED" && exit 1

echo "	--> Create the CLIENT keystore"
! [ -f amq-client.ks ] && keytool -genkeypair -keystore amq-client.ks -storepass password -keyalg RSA -alias amq-client -dname "CN=${OPENSHIFT_PRIMARY_USER}" -keypass password
! [ $? == 0 ] && echo "FAILED" && exit 1

echo "	--> import the previous exported brokers certificate into a CLIENT truststore"
! [ -f amq-client.ts ] && echo yes |  keytool -import -alias amq-server -keystore amq-client.ts -storepass password -file amq-server_cert
! [ $? == 0 ] && echo "FAILED" && exit 1

echo "	--> If you want to make trusted also the client, you must export the clients certificate from the keystore"
! [ -f amq-client_cert ] && keytool -export -alias amq-client -keystore amq-client.ks -storepass password -file amq-client_cert
! [ $? == 0 ] && echo "FAILED" && exit 1

echo "	--> Import the clients exported certificate into a broker SERVER truststore"

echo yes | keytool -import -alias amq-client -keystore amq-server.ts -storepass password -file amq-client_cert
! [ $? == 0 ] && echo "FAILED" && exit 1

# --- 2 lines below commented out ???
echo "	--> Verify the contents of the keystore"
[ "`keytool -list -keystore amq-server.ts -storepass password| grep amq-server | wc -l`" == 0 ] && echo "FAILED" && exit 1

echo "	--> Verify the contents of the keystore"
[ "`keytool -list -keystore amq-server.ks -storepass password| grep amq-server | wc -l`" == 0 ] && echo "FAILED" && exit 1
echo "	--> Verify the contents of the keystore"
[ "`keytool -list -keystore amq-client.ts -storepass password | grep amq-server | wc -l`" == 0 ] && echo "FAILED" && exit 1
echo "	--> Verify the contents of the keystore"
[ "`keytool -list -keystore amq-client.ks -storepass password |  grep amq-client | wc -l`" == 0 ] && echo "FAILED" && exit 1

echo "	--> Log into openshift"
oc login ${OPENSHIFT_PRIMARY_MASTER} --username=${OPENSHIFT_PRIMARY_USER} --password=${OPENSHIFT_PRIMARY_USER_PASSWORD} --insecure-skip-tls-verify=false
! [ $? == 0 ] && echo "FAILED" && exit 1

echo " "
echo " ---------  Step 1 -----------------"
echo "	--> Create a new project:" ${OPENSHIFT_PRIMARY_PROJECT}
oc project ${OPENSHIFT_PRIMARY_PROJECT}
! [ $? == 0 ] && oc new-project ${OPENSHIFT_PRIMARY_PROJECT}
! [ $? == 0 ] && echo "FAILED" && exit 1

echo " "
echo " ---------  Step 2 -----------------"
echo "	--> Create a service account to be used for the A-MQ deployment"
# 
if [ `oc get serviceaccounts | grep amq-service-account | wc -l ` == 0 ]; then
   echo '{"kind": "ServiceAccount", "apiVersion": "v1", "metadata": {"name": "amq-service-account"}}' | oc create -f -
else 
   echo "FAILED" && exit 1
fi 

echo " "
echo " ---------  Step 3 ------------------"
echo "	--> use the broker keyStore file to create the A-MQ secret"
oc get secret/amq-app-secret 2>/dev/null || oc secrets new amq-app-secret amq-server.ks amq-server.ts
! [ $? == 0 ] && echo "FAILED" && exit 1

echo " "
echo " ---------  Step 4 ------------------"
echo "	--> Add the secret to the service account created earlier"
oc describe sa/amq-service-account | oc secrets add sa/amq-service-account secret/amq-app-secret
! [ $? == 0 ] && echo "FAILED" && exit 1
#

echo " "
echo " ---------  Step 5 ------------------"
echo "	--> Add the view role to the service account to enable viewing all the resources in the project namespace, which is necessary for managing the cluster when using the Kubernetes REST API agent for discovering the mesh endpoints"

#[ "`oc describe policyBindings :default | grep -A5 'RoleBinding\[view\]' | grep amq-service-account | wc -l`" == 0 ] && oc policy add-role-to-user view system:serviceaccount:${OPENSHIFT_PRIMARY_PROJECT}:amq-service-account ! [ $? == 0 ] && echo "FAILED" && exit 1
#error: the server doesn't have a resource type "policyBindings"
oc policy add-role-to-user view system:serviceaccount:${OPENSHIFT_PRIMARY_PROJECT}:amq-service-account 
! [ $? == 0 ] && echo "FAILED" && exit 1

echo $'\n ---------  Step 6 ------------------'
echo "	--> add the amq-broker-72-ssl imagestream to the nammespace"
oc create -n ${OPENSHIFT_PRIMARY_PROJECT}  -f amq-broker-7-image-streams.yaml

echo $'\n ---------  Step 7 ------------------'
echo "	--> add the amq-broker-72-ssl template to the nammespace"
echo " templates are located here: https://github.com/jboss-container-images/jboss-amq-7-broker-openshift-image/tree/amq-broker-72/templates"
echo "	--> add the amq-broker-72-ssl template to the nammespace"

oc create -n ${OPENSHIFT_PRIMARY_PROJECT} -f amq-broker-72-ssl.json
#
# this is from https://github.com/jboss-container-images/jboss-amq-7-broker-openshift-image/tree/amq-broker-72
# you must specify the required PARAMS AMQ_TRUSTSTORE_PASSWORD and AMQ_KEYSTORE_PASSWORD
#
#oc process -f amq-broker-72-ssl.json | oc create -f -
# add error check??

#echo $TEST1 "---------------afdsafadad"

echo "	--> Create a new application from the amq63-ssl template"
#
echo " ---------  Step 8 ------------------"
echo  `oc get dc -l app=fuse-amq `
echo " ---------  Step 9 ------------------"
if [ `oc get dc -l app=fuse-amq | wc -l` == 0 ] ; then
   oc new-app amq-broker-72-ssl -l app=fuse-amq -p IMAGE_STREAM_NAMESPACE=${OPENSHIFT_PRIMARY_PROJECT} -p APPLICATION_NAME=${OPENSHIFT_APPLICATION_NAME} -p AMQ_PROTOCOL=openwire -p AMQ_QUEUES=testQueue -p AMQ_USER=admin -p AMQ_PASSWORD=password -p AMQ_TRUSTSTORE=amq-server.ts -p AMQ_TRUSTSTORE_PASSWORD=password -p AMQ_KEYSTORE=amq-server.ks -p AMQ_KEYSTORE_PASSWORD=password -p AMQ_GLOBAL_MAX_SIZE=256M 
else 
   echo "FAILED" && exit 1
fi

echo " ---------  Step 10 ------------------"
echo "	--> Verify the application is working normally"
oc status --suggest

echo " ---------  Step 11 ------------------"
oc status 
! [ $? == 0 ] && echo "FAILED" && exit 1

echo " ---------  Step 12 ------------------"
echo "	--> Create a tcp ssl passthrough route to the frontend"
# the broker now creates a route for Jolokia, we are just verifing that an ssl route doesn't exist
TCP_SSL_ROUTE=${OPENSHIFT_APPLICATION_NAME}-amq-tcp-ssl
ROUTE=`oc get route -l app=fuse-amq`
if [[ ${ROUTE} =~ "amq-tcp-ssl" ]] ; then 
#  if the route already exists, fail
  echo "FAILED to create ${TCP_SSL_ROUTE} passthrough route"
  exit 1
else 
  oc create route passthrough ${OPENSHIFT_APPLICATION_NAME} --service=${TCP_SSL_ROUTE}
fi

echo " ---------  Step 13 -------------------"
echo "    --> Verify the application is working normally"
oc get all
if [ 'oc get all | wc -l' == 0 ]; then
   echo "FAILED" && exit 1
else
   echo "Successfully created "$OPENSHIFT_APPLICATION_NAME
fi

echo "	--> MANUALLY CREATE an maven project using the camel-archetype-activemq archetype in JBoss Developer Studio using:"
echo "		--> Camel Context: "

cat > camel-context-fragment.xml << EOF_AMQ_CAMEL_CONTEXT
<bean id="activemq" class="org.apache.activemq.ActiveMQSslConnectionFactory">
	<property name="brokerURL"          value="failover://ssl://${OPENSHIFT_APPLICATION_NAME}-${OPENSHIFT_PRIMARY_PROJECT}.${OPENSHIFT_PRIMARY_APPS}:443" />
	<property name="userName"           value="admin" />
	<property name="password"           value="password" />
	<property name="trustStore"         value="$(pwd)/amq-client.ts" />
	<property name="trustStorePassword" value="password" />
	<property name="keyStore"           value="$(pwd)/amq-client.ks" />
	<property name="keyStorePassword"   value="password" />
</bean>
EOF_AMQ_CAMEL_CONTEXT
cat camel-context-fragment.xml

echo "Done"
