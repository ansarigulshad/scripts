#!/bin/bash
# Script to delete historical data from ambari database


yum clean all
yum install jq -y

_AMBARI_HOST=$(hostname -f)
_AMBARI_PORT="8080"
_AMBARI_PROTOCOL=http
_AMBARI_ADMIN_USER=admin
_AMBARI_ADMIN_PASSWORD=gansari
_AMBARI_API="$_AMBARI_PROTOCOL://$_AMBARI_HOST:$_AMBARI_PORT/api/v1"

_DATA_TO_BE_PURGED=$(date --date="30 days ago" +"%Y-%m-%d")


_CLUSTER_NAME=$(curl -k -u $_AMBARI_ADMIN_USER:$_AMBARI_ADMIN_PASSWORD -H 'X-Requested-By: ambari' $_AMBARI_API/clusters | jq -r '.items[].Clusters.cluster_name')

echo "Purge ambari history older than $_DATA_TO_BE_PURGED....."
ambari-server db-purge-history -s  --cluster-name $_CLUSTER_NAME --from-date $_DATA_TO_BE_PURGED ; ambari-server start

echo "Done"
