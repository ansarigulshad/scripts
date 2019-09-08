
### Setup openLDAP server

#### 1. Download script
```
yum install git -y
git clone https://github.com/ansarigulshad/scripts.git
cd scripts/shell/openldap/
chmod +x *.sh
```

#### 2. Update openldap.properties file
```
# cat openldap.properties

LdapAdmin=ldapadmin
LdapAdminPassword="hadoop123"
MyPass=`slappasswd -s $LdapAdminPassword`
BaseDomain="dc=hortonworks,dc=com"
LdapAdminDN="cn=$LdapAdmin,$BaseDomain"
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
#### 6. Validate (optional)
```
# ldapsearch -x -H ldap://$(hostname -f):389 -D 'cn=ldapadmin,dc=hortonworks,dc=com' -w 'hadoop123' -b 'dc=hortonworks,dc=com'
```
