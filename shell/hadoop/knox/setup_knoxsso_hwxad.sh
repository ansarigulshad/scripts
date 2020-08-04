#/bin/bash

yum install jq -y

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

_AMBARI_HOST=$(hostname -f)
_AMBARI_PORT="8080"
_AMBARI_PROTOCOL=http
_AMBARI_ADMIN_USER=admin
_AMBARI_ADMIN_PASSWORD=gansari
_TARGETSCRIPT="/var/lib/ambari-server/resources/scripts/configs.py"
_AMBARI_API="$_AMBARI_PROTOCOL://$_AMBARI_HOST:$_AMBARI_PORT/api/v1"
_CLUSTER_NAME=$(curl -k -u $_AMBARI_ADMIN_USER:$_AMBARI_ADMIN_PASSWORD -H 'X-Requested-By: ambari' $_AMBARI_API/clusters | jq -r '.items[].Clusters.cluster_name')


_CMD="${_TARGETSCRIPT} -l ${_AMBARI_HOST} -t ${_AMBARI_PORT} -n ${_CLUSTER_NAME}  -s ${_AMBARI_PROTOCOL} -u ${_AMBARI_ADMIN_USER} -p ${_AMBARI_ADMIN_PASSWORD}"

cat > /tmp/knoxsso.json <<EOFILE
{
  "properties": {
    "content": "<topology>\n<gateway>\n<provider>\n<role>webappsec</role>\n<name>WebAppSec</name>\n<enabled>true</enabled>\n<param>\n<name>xframe.options.enabled</name>\n<value>true</value>\n</param>\n</provider>\n<provider>\n<role>authentication</role>\n<name>ShiroProvider</name>\n<enabled>true</enabled>\n<param>\n<name>sessionTimeout</name>\n<value>30</value>\n</param>\n<param>\n<name>redirectToUrl</name>\n<value>/gateway/knoxsso/knoxauth/login.html</value>\n</param>\n<param>\n<name>restrictedCookies</name>\n<value>rememberme,WWW-Authenticate</value>\n</param>\n<param>\n<name>main.ldapRealm</name>\n<value>org.apache.hadoop.gateway.shirorealm.KnoxLdapRealm</value>\n</param>\n<param>\n<name>main.ldapContextFactory</name>\n<value>org.apache.hadoop.gateway.shirorealm.KnoxLdapContextFactory</value>\n</param>\n<param>\n<name>main.ldapRealm.contextFactory</name>\n<value>\$ldapContextFactory</value>\n</param>\n<param>\n<name>main.ldapRealm.contextFactory.url</name>\n<value>$_LDAP_URL</value>\n</param>\n<param>\n<name>main.ldapRealm.contextFactory.systemUsername</name>\n<value>$_LDAP_BIND_DN</value>\n</param>\n<param>\n<name>main.ldapRealm.contextFactory.systemPassword</name>\n<value>$_LDAP_BIND_PASSWORD</value>\n</param>\n<param>\n<name>main.ldapRealm.contextFactory.authenticationMechanism</name>\n<value>simple</value>\n</param>\n<param>\n<name>main.ldapRealm.searchBase</name>\n<value>$_LDAP_SEARCH_BASE</value>\n</param>\n<param>\n<name>main.ldapRealm.userObjectClass</name>\n<value>$_LDAP_userObjectClass</value>\n</param>\n<param>\n<name>main.ldapRealm.userSearchAttributeName</name>\n<value>$_LDAP_userSearchAttributeName</value>\n</param>\n<param>\n<name>main.ldapRealm.authorizationEnabled</name>\n<value>false</value>\n</param>\n<param>\n<name>main.ldapRealm.groupSearchBase</name>\n<value>$_LDAP_SEARCH_BASE</value>\n</param>\n<param>\n<name>main.ldapRealm.groupObjectClass</name>\n<value>$_LDAP_groupObjectClass</value>\n</param>\n<param>\n<name>main.ldapRealm.groupIdAttribute</name>\n<value>$_LDAP_groupIdAttribute</value>\n</param>\n<!--\n<param>\n<name>main.ldapRealm.userDnTemplate</name>\n<value>uid={0},ou=people,dc=hadoop,dc=apache,dc=org</value>\n</param>\n<param>\n<name>main.ldapRealm.contextFactory.url</name>\n<value>ldap://localhost:33389</value>\n</param>\n-->\n<param>\n<name>main.ldapRealm.authenticationCachingEnabled</name>\n<value>false</value>\n</param>\n<param>\n<name>urls./**</name>\n<value>authcBasic</value>\n</param>\n</provider>\n<provider>\n<role>identity-assertion</role>\n<name>Default</name>\n<enabled>true</enabled>\n</provider>\n</gateway>\n\n<application>\n<name>knoxauth</name>\n</application>\n<service>\n<role>KNOXSSO</role>\n<param>\n<name>knoxsso.cookie.secure.only</name>\n<value>false</value>\n</param>\n<param>\n<name>knoxsso.token.ttl</name>\n<value>36000000</value>\n</param>\n<param>\n<name>knoxsso.redirect.whitelist.regex</name>\n<value>^https?:\\\/\\\/((.*)\\\.coelab\\\.cloudera\\\.com|localhost|127\\\.0\\\.0\\\.1|0:0:0:0:0:0:0:1|::1):[0-9].*\$</value>\n</param>\n</service>\n</topology>"
  }
}
EOFILE

${_CMD} -a get -c knoxsso-topology -f /tmp/knoxsso.json.orig

${_CMD} -a set -c knoxsso-topology -f /tmp/knoxsso.json

curl -k -u $_AMBARI_ADMIN_USER:$_AMBARI_ADMIN_PASSWORD -H 'X-Requested-By: ambari'  $_AMBARI_API/clusters/$_CLUSTER_NAME/services/KNOX -X PUT \
-d '{"RequestInfo": {"context" :"Stop Knox - Gulshad"}, "Body": {"ServiceInfo": {"state": "INSTALLED"}}}'

curl -k -u $_AMBARI_ADMIN_USER:$_AMBARI_ADMIN_PASSWORD -H 'X-Requested-By: ambari'  $_AMBARI_API/clusters/$_CLUSTER_NAME/services/KNOX -X PUT \
-d '{"RequestInfo": {"context" :"Start Knox - Gulshad"}, "Body": {"ServiceInfo": {"state": "STARTED"}}}'



# end




