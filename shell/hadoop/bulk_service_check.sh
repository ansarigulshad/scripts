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
# Install jq package if it doesnt exist
# Ubuntu
# if ! sudo dpkg-query -W -f='${Status}' jq  | grep "ok installed"; then sudo apt install jq; fi

# RHEL
sudo rpm -qa | grep -qw jq || sudo yum install jq -y

# Set variables
_ambari_admin_user=admin
_ambari_admin_password=gansari
_ambari_hostname=$(hostname -f)
_ambari_port=8080
_ambari_protocol=http
_ambari_api="${_ambari_protocol}://${_ambari_hostname}:${_ambari_port}/api/v1"
#_cluster_name=hdp_cluster
_cluster_name=`curl -k -H 'X-Requested-By: ambari' -u ${_ambari_admin_user}:${_ambari_admin_password} ${_ambari_api}/clusters | jq -r '.items[].Clusters.cluster_name'`

_unused_service_list=`curl -k -H 'X-Requested-By: ambari' -u ${_ambari_admin_user}:${_ambari_admin_password}  "${_ambari_api}/clusters/${_cluster_name}/services" | jq -r '.items[].ServiceInfo.service_name'


for myservice in $_unused_service_list
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
curl -k -u ${_ambari_admin_user}:${_ambari_admin_password} -H 'X-Requested-By: ambari' "${_ambari_api}/${_cluster_name}/requests" -d @/var/tmp/$myservice-payload.json
done


#end
