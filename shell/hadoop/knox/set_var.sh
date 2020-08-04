# Install jq package
yum install jq -y

# ++++++++++ Ambari-Server Details ++++++++++
_AMBARI_HOST=$(hostname -f)
_AMBARI_PORT="8080"
_AMBARI_PROTOCOL=http
_AMBARI_ADMIN_USER=admin
_AMBARI_ADMIN_PASSWORD=gansari
_TARGETSCRIPT="/var/lib/ambari-server/resources/scripts/configs.py"
_AMBARI_API="$_AMBARI_PROTOCOL://$_AMBARI_HOST:$_AMBARI_PORT/api/v1"
_CLUSTER_NAME=$(curl -k -u $_AMBARI_ADMIN_USER:$_AMBARI_ADMIN_PASSWORD -H 'X-Requested-By: ambari' $_AMBARI_API/clusters | jq -r '.items[].Clusters.cluster_name')

_CMD="${_TARGETSCRIPT} -l ${_AMBARI_HOST} -t ${_AMBARI_PORT} -n ${_CLUSTER_NAME}  -s ${_AMBARI_PROTOCOL} -u ${_AMBARI_ADMIN_USER} -p ${_AMBARI_ADMIN_PASSWORD}"

# ++++++++++ LDAP Details ++++++++++
_LDAP_URL="ldap://172.26.126.78:389"
_LDAP_BIND_DN="CN=test1,OU=hortonworks,DC=SUPPORT,DC=COM"
_LDAP_BIND_PASSWORD=hadoop12345!
_LDAP_SEARCH_BASE="OU=hortonworks,DC=SUPPORT,DC=COM"
_LDAP_userObjectClass=person
_LDAP_userSearchAttributeName=sAMAccountName
_LDAP_groupObjectClass=group
_LDAP_groupIdAttribute=cn
_LDAP_groupMemberAttribute=member
_LDAP_groupDistinguishedName=distinguishedName
