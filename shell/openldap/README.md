
### Setup openLDAP server

##### __Note: This setup is tested on Centos7 version only

#### 1. Download script
```
yum clean all
yum install git -y
git clone https://github.com/ansarigulshad/scripts.git
cd scripts/shell/openldap/
chmod +x *.sh
```

#### 2. Update openldap.properties file
```
# cat openldap.properties

ARG_L_ADMIN=ldapadmin
ARG_L_ADMINPASSWORD="hadoop123"
ARG_MyPass=`slappasswd -s $ARG_L_ADMINPASSWORD`
ARG_DOMAIN=HORTONWORKS.COM
ARG_DOMAINCONTROLLER="DC=HORTONWORKS,DC=COM"
ARG_BINDDN="CN=$ARG_L_ADMIN,$ARG_DOMAINCONTROLLER"


ARG_LDAPURI="ldap://$(hostname -f):389"
ARG_SEARCHBASE=$ARG_DOMAINCONTROLLER
#ARG_BINDDN=CN=Administrator,CN=Users,DC=HORTONWORKS,DC=COM
#ARG_USERPSWD=Hadoop123!

# Users will be created under this(ARG_USER_BASE) OU, Make sure the OU path is correct
ARG_USER_BASE=OU=Users,OU=Hadoop,$ARG_DOMAINCONTROLLER
# Groups will be created under this(ARG_GROUP_BASE) OU, Make sure the OU path is correct
ARG_GROUP_BASE=OU=Groups,OU=Hadoop,$ARG_DOMAINCONTROLLER

# Default password for all users
ARG_UserPass=Welcome123
ARG_NewUserPass=`echo -e "${ARG_UserPass}" | iconv -f UTF8 -t UTF16LE | base64 -w 0`


LDAP_HOST=$(echo $ARG_LDAPURI | cut -d ":" -f2 | cut -d "/" -f3)
LDAP_PORT=$(echo $ARG_LDAPURI | cut -d ":" -f3)
```

#### 3. Execute _`setup_openldap_server.sh`_ script

```
sh setup_openldap_server.sh
```


#### 4. Execute _`create_users_openldap.sh`_ script

```
sh create_users_openldap.sh
```

#### 5. Execute _`create_groups_openldap.sh`_ script

```
sh create_groups_openldap.sh
```
#### 6. Add users to groups
```
sh add_users_to_groups.sh
```

#### 7. Validate
```
# ldapsearch -x -H ldap://$(hostname -f):389 -D 'cn=ldapadmin,dc=hortonworks,dc=com' -w 'hadoop123' -b 'dc=hortonworks,dc=com'
```
