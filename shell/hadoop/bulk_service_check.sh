#!/bin/bash
#
#
##########################################################################################################
#Script Name	 : bulk_service_check.sh
#Description	 : This Script is developed to bulk service check on HDP cluster using ambari API calls
#Author        : Gulshad Ansari
#LinkedIn      : https://linkedin.com/in/gulshad/
#
#
#Note
#   Script requires curl and jq command. Make sure these commands are installed on node
#
# 
##########################################################################################################
#
#
#
#
#

# Set variables
_ambari_admin_user=admin
_ambari_admin_password=gansari
_clustername=c1230
_ambari_hostname=c1230-node1.coelab.cloudera.com
_ambari_port=8080
_ambari_protocol=http

# Install jq
yum install jq -y

for myservice in `cat /var/tmp/hdp_services.list`
do
# if condition for zookeeper as ZK command is different than other services
if [ $myservice == 'ZOOKEEPER' ]
then
  MY_COMMAND=`echo $myservice"_QUORUM_SERVICE_CHECK"`
else
  MY_COMMAND=`echo $myservice"_SERVICE_CHECK"`
fi
# create payload for each service
cat > /var/tmp/$myservice-payload.json <<EOF
{
  "RequestInfo": {
    "context": "$myservice Service Check",
    "command": "$MY_COMMAND"
  },
  "Requests/resource_filters": [
    {
      "service_name": "$myservice"
    }
  ]
}
EOF
# run service check for all services
curl -k -u $_ambari_admin_user:$_ambari_admin_password -H 'X-Requested-By: ambari' "$_ambari_protocol://$_ambari_hostname:$_ambari_port/api/v1/clusters/$_clustername/requests" \
-d @/var/tmp/$myservice-payload.json
done


#end
