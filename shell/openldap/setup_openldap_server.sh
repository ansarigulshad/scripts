#!/usr/bin/env bash

#################################################################
# Script to setup openLDAP server on centos/RHEL server        ##
# Script will take inputs from users.list file                 ##
# Users wil be added under OU specied in openldap.properties file    ##
#                                                     	       ##
#Author - Gulshad Ansari		                       ##
#Email: gulshad.ansari@hotmail.com                     	       ##
#LinkedIn : https://www.linkedin.com/in/gulshad/       	       ##
#################################################################

yum clean all -y
yum -y install openldap-servers openldap-clients
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown ldap. /var/lib/ldap/DB_CONFIG

service slapd start
chkconfig slapd on
# systemctl start slapd
# systemctl enable slapd


LOC=`pwd`
OPENLDAP_PROPETIES=openldap.properties
source $LOC/$OPENLDAP_PROPETIES

netstat -antup | grep -i 389


echo -e "dn: olcDatabase={0}config,cn=config\nchangetype: modify\nadd: olcRootPW\nolcRootPW: $ARG_MyPass"  > /var/tmp/chrootpw.ldif


ldapadd -Y EXTERNAL -H ldapi:/// -f /var/tmp/chrootpw.ldif

# Import basic Schemas.
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

ARG_MyPass=`slappasswd -s $ARG_L_ADMINPASSWORD`


#echo -e "dn: olcDatabase={1}monitor,cn=config\nchangetype: modify\nreplace: olcAccess\nolcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth"\n  read by dn.base="$ARG_BINDDN" read by * none\n\ndn: olcDatabase={2}hdb,cn=config\nchangetype: modify\nreplace: olcSuffix\nolcSuffix: $ARG_DOMAINCONTROLLER\n\ndn: olcDatabase={2}hdb,cn=config\nchangetype: modify\nreplace: olcRootDN\nolcRootDN: $ARG_BINDDN\n\ndn: olcDatabase={2}hdb,cn=config\nchangetype: modify\nadd: olcRootPW\nolcRootPW: $ARG_MyPass\n\ndn: olcDatabase={2}hdb,cn=config\nchangetype: modify\nadd: olcAccess\nolcAccess: {0}to attrs=userPassword,shadowLastChange by\n dn="$ARG_BINDDN" write by anonymous auth by self write by * none\nolcAccess: {1}to dn.base="" by * read\nolcAccess: {2}to * by dn="$ARG_BINDDN" write by * read\n" > /var/tmp/chdomain.ldif

cat > /var/tmp/chdomain.ldif <<EOFILE
dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth"
  read by dn.base="$ARG_BINDDN" read by * none

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: $ARG_DOMAINCONTROLLER

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: $ARG_BINDDN

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: $ARG_MyPass

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange by
 dn="$ARG_BINDDN" write by anonymous auth by self write by * none
olcAccess: {1}to dn.base="" by * read
olcAccess: {2}to * by dn="$ARG_BINDDN" write by * read" 
EOFILE

ldapmodify -Y EXTERNAL -H ldapi:/// -f /var/tmp/chdomain.ldif

#echo -e "\ndn: $ARG_DOMAINCONTROLLER\nobjectClass: top\nobjectClass: dcObject\nobjectclass: organization\no: `echo $ARG_DOMAINCONTROLLER | cut -d ',' -f1 | cut -d '=' -f2`\ndc: `echo $ARG_DOMAINCONTROLLER | cut -d ',' -f1 | cut -d '=' -f2`\n\ndn: $ARG_BINDDN\nobjectClass: organizationalRole\ncn: ldapadmin\ndescription: Directory ldapadmin\n\ndn: ou=People,$ARG_DOMAINCONTROLLER\nobjectClass: organizationalUnit\nou: People\n\ndn: ou=Group,$ARG_DOMAINCONTROLLER\nobjectClass: organizationalUnit\nou: Group\n\ndn: ou=Users,$ARG_DOMAINCONTROLLER\nobjectClass: organizationalUnit\nou: Users\n\ndn: ou=Hadoop,$ARG_DOMAINCONTROLLER\nobjectClass: organizationalUnit\nou: Hadoop\ndescription: organizationalUnit for BigData & Hadoop" > /var/tmp/ARG_DOMAINCONTROLLER.ldif


echo -e "\ndn: $ARG_DOMAINCONTROLLER\nobjectClass: top\nobjectClass: dcObject\nobjectclass: organization\no: `echo $ARG_DOMAINCONTROLLER | cut -d ',' -f1 | cut -d '=' -f2`\ndc: `echo $ARG_DOMAINCONTROLLER | cut -d ',' -f1 | cut -d '=' -f2`\n\ndn: $ARG_BINDDN\nobjectClass: organizationalRole\ncn: ldapadmin\ndescription: Directory ldapadmin\n\ndn: ou=People,$ARG_DOMAINCONTROLLER\nobjectClass: organizationalUnit\nou: People\n\ndn: ou=Group,$ARG_DOMAINCONTROLLER\nobjectClass: organizationalUnit\nou: Group\n\ndn: ou=Users,$ARG_DOMAINCONTROLLER\nobjectClass: organizationalUnit\nou: Users\n\ndn: ou=Hadoop,$ARG_DOMAINCONTROLLER\nobjectClass: organizationalUnit\nou: Hadoop\ndescription: organizationalUnit for BigData & Hadoop\n\ndn: ou=Users,ou=Hadoop,$ARG_DOMAINCONTROLLER\nobjectClass: organizationalUnit\nou: Hadoop Users\ndescription: organizationalUnit for BigData & Hadoop Users\n\ndn: ou=Groups,ou=Hadoop,$ARG_DOMAINCONTROLLER\nobjectClass: organizationalUnit\nou: Hadoop Groups\ndescription: organizationalUnit for BigData & Hadoop Groups" > /var/tmp/ARG_DOMAINCONTROLLER.ldif


ldapadd -x -D $ARG_BINDDN -w $ARG_L_ADMINPASSWORD -f /var/tmp/ARG_DOMAINCONTROLLER.ldif


# done


echo -e "\n\nSetup Completed Successfully:\n"

echo -e "=================="
echo -e "LDAP Attributes"     > $LOC/myldapserverdetails.out
echo -e "==================" >> $LOC/myldapserverdetails.out

echo -e "LDAP Server Host = $LDAP_HOST" >> $LOC/myldapserverdetails.out
echo -e "LDAP Server port = $LDAP_PORT" >> $LOC/myldapserverdetails.out
echo -e "User Object Class = posixAccount" >> $LOC/myldapserverdetails.out
echo -e "Username Attribute = uid"  >> $LOC/myldapserverdetails.out
echo -e "Group Object Class = posixGroup" >> $LOC/myldapserverdetails.out
echo -e "Group Name Attribute = cn"  >> $LOC/myldapserverdetails.out
echo -e "Group Member Attribute = memberUid"  >> $LOC/myldapserverdetails.out
echo -e "Distinguished name attribute = dn"  >> $LOC/myldapserverdetails.out
echo -e "Search Base DN = $ARG_DOMAINCONTROLLER"  >> $LOC/myldapserverdetails.out
echo -e "managerDn = $ARG_BINDDN"  >> $LOC/myldapserverdetails.out
echo -e "managerDnPassword = $ARG_L_ADMINPASSWORD"  >> $LOC/myldapserverdetails.out

cat $LOC/myldapserverdetails.out


#EndOfScript
