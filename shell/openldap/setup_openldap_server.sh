#!/bin/bash

#################################################################
# Script to setup openLDAP server on centos/RHEL server        ##
# Script will take inputs from users.list file                 ##
# Users wil be added under OU specied in ad.properties file    ##
#                                                     	       ##
#Author - Gulshad Ansari		                       ##
#Email: gulshad.ansari@hotmail.com                     	       ##
#LinkedIn : https://www.linkedin.com/in/gulshad/       	       ##
#################################################################


#LdapAdmin=ldapadmin
#LdapAdminPassword="hadoop123"
#MyPass=`slappasswd -s $LdapAdminPassword`
#BaseDomain="dc=hortonworks,dc=com"
#LdapAdminDN="cn=$LdapAdmin,$BaseDomain"


LOC=`pwd`
OPENLDAP_PROPETIES=openldap.properties
source $LOC/$OPENLDAP_PROPETIES


yum -y install openldap-servers openldap-clients
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown ldap. /var/lib/ldap/DB_CONFIG
systemctl start slapd
systemctl enable slapd

netstat -antup | grep -i 389


echo -e "dn: olcDatabase={0}config,cn=config\n\nchangetype: modify\nadd: olcRootPW\nolcRootPW: $MyPass"  > /var/tmp/chrootpw.ldif


ldapadd -Y EXTERNAL -H ldapi:/// -f /var/tmp/chrootpw.ldif

# Import basic Schemas.
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

MyPass=`slappasswd -s $LdapAdminPassword`


echo -e "dn: olcDatabase={1}monitor,cn=config\nchangetype: modify\nreplace: olcAccess\nolcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth"\n  read by dn.base="$LdapAdminDN" read by * none\n\ndn: olcDatabase={2}hdb,cn=config\nchangetype: modify\nreplace: olcSuffix\nolcSuffix: $BaseDomain\n\ndn: olcDatabase={2}hdb,cn=config\nchangetype: modify\nreplace: olcRootDN\nolcRootDN: $LdapAdminDN\n\ndn: olcDatabase={2}hdb,cn=config\nchangetype: modify\nadd: olcRootPW\nolcRootPW: $MyPass\n\ndn: olcDatabase={2}hdb,cn=config\nchangetype: modify\nadd: olcAccess\nolcAccess: {0}to attrs=userPassword,shadowLastChange by\n dn="$LdapAdminDN" write by anonymous auth by self write by * none\nolcAccess: {1}to dn.base="" by * read\nolcAccess: {2}to * by dn="$LdapAdminDN" write by * read\n" > /var/tmp/chdomain.ldif


ldapmodify -Y EXTERNAL -H ldapi:/// -f /var/tmp/chdomain.ldif

echo -e "\ndn: $BaseDomain\nobjectClass: top\nobjectClass: dcObject\nobjectclass: organization\no: `echo $BaseDomain | cut -d ',' -f1 | cut -d '=' -f2`\ndc: `echo $BaseDomain | cut -d ',' -f1 | cut -d '=' -f2`\n\ndn: $LdapAdminDN\nobjectClass: organizationalRole\ncn: Manager\ndescription: Directory Manager\n\ndn: ou=People,$BaseDomain\nobjectClass: organizationalUnit\nou: People\n\ndn: ou=Group,$BaseDomain\nobjectClass: organizationalUnit\nou: Group\n\ndn: ou=Users,$BaseDomain\nobjectClass: organizationalUnit\nou: Users\n\ndn: ou=Hadoop,$BaseDomain\nobjectClass: organizationalUnit\nou: Hadoop\ndescription: organizationalUnit for BigData & Hadoop" > /var/tmp/basedomain.ldif



ldapadd -x -D $LdapAdminDN -w $LdapAdminPassword -f /var/tmp/basedomain.ldif
