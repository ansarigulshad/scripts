#!/bin/bash
# Usage :
# Script to restart all services at 11:00 AM IST on first Sunday of the month.
# Use below scrontab to enable restart on Sunday
# 30 5 * * Sun /etc/ambari-server/scripts/restart-all-services.sh
#
#
set -x


if [ `date +%d` -gt 7 ] ; then
   exit
else
(
# Set below values as per env
AMBARI_HOST=`hostname -f`
AMBARI_PORT=8080
AMBARI_ADMIN_USER=admin
AMBARI_ADMIN_PASSWORD=admin
AMBARI_PROTOCOL="http"
AMBARI_API="${AMBARI_PROTOCOL}://${AMBARI_HOST}:${AMBARI_PORT}/api/v1"
CLUSTER_NAME=`curl -k -H 'X-Requested-By: ambari' -u ${AMBARI_ADMIN_USER}:${AMBARI_ADMIN_PASSWORD} ${AMBARI_API}/clusters | grep "cluster_name" | awk -F'"' '{print $4}'`
# STOP ALL SERVICES
curl -k -H 'X-Requested-By: ambari' -X PUT -u ${AMBARI_ADMIN_USER}:${AMBARI_ADMIN_PASSWORD} "${AMBARI_API}/clusters/${CLUSTER_NAME}/services?" -d '{"RequestInfo":{"context":"_PARSE_.STOP.ALL_SERVICES","operation_level":{"level":"CLUSTER","cluster_name":"'"$CLUSTER_NAME"'"}},"Body":{"ServiceInfo":{"state":"INSTALLED"}}}'
sleep 300
# STAR ALL SERVICES
curl -k -H 'X-Requested-By: ambari' -X PUT -u ${AMBARI_ADMIN_USER}:${AMBARI_ADMIN_PASSWORD} "${AMBARI_API}/clusters/${CLUSTER_NAME}/services?" -d '{"RequestInfo":{"context":"_PARSE_.START.ALL_SERVICES","operation_level":{"level":"CLUSTER","cluster_name":"'"$CLUSTER_NAME"'"}},"Body":{"ServiceInfo":{"state":"STARTED"}}}'
if [ $? -ne 0 ]; then
        sleep 300
        curl -k -H 'X-Requested-By: ambari' -X PUT -u ${AMBARI_ADMIN_USER}:${AMBARI_ADMIN_PASSWORD} "${AMBARI_API}/clusters/${CLUSTER_NAME}/services?" -d '{"RequestInfo":{"context":"_PARSE_.START.ALL_SERVICES","operation_level":{"level":"CLUSTER","cluster_name":"'"$CLUSTER_NAME"'"}},"Body":{"ServiceInfo":{"state":"STARTED"}}}'
fi
)| sudo tee -a /var/log/restart-all-services-`date +%d%m%y`.log

fi
