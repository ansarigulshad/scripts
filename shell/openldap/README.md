
### Setup openLDAP server

#### 1. Download script
```
yum install git -y
git clone https://github.com/ansarigulshad/scripts.git
cd to scripts/shell/ActiveDirectory/
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
