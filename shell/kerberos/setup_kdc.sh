#!/bin/bash

########################################
#Script to setup and configure MIT KDC##
#Author - Gulshad Ansari			  ##
########################################

LOC=`pwd`
KRB_PROPERTIES=krb.properties
source $LOC/$KRB_PROPERTIES


currect_time_stamp()
{
	echo "`date +%Y-%m-%d" "%H:%M:%S`"
}

setup_kdc()
{
	#Install Kerberos packages
	echo -e "\n`currect_time_stamp` Installing kerberos RPMs"
	yum -y install krb5-server krb5-libs krb5-workstation

	#Configure Kerberos
	echo -e "\n`currect_time_stamp` Configuring Kerberos"
	echo -e "\n`currect_time_stamp` Configuring krb5.conf"
	sed -i.bak "s/EXAMPLE.COM/$REALM/g" $LOC/krb5.conf.template
	sed -i.bak "s/kerberos.example.com/$KDC_HOST/g" $LOC/krb5.conf.template
	cat $LOC/krb5.conf.template > /etc/krb5.conf
	echo -e "\n`currect_time_stamp` Configuring kdc.conf"
	sed -i.bak "s/EXAMPLE.COM/$REALM/g" /var/kerberos/krb5kdc/kdc.conf	
	echo -e "\n`currect_time_stamp` Configuring kadm5.acl"
	sed -i.bak "s/EXAMPLE.COM/$REALM/g" /var/kerberos/krb5kdc/kadm5.acl

	#Create Database
	echo -e "\n`currect_time_stamp` Creating kerberos database"
	kdb5_util create -s -P $KRB_MASTER_SECRET

	#Start Services
	echo -e "\n`currect_time_stamp` Starting KDC services"
	service krb5kdc start
	service kadmin start
	chkconfig krb5kdc on
	chkconfig kadmin on

	#Create admin principal
	echo -e "\n`currect_time_stamp` Creating admin principal"
	kadmin.local -q "addprinc -pw hadoop admin/admin"

#	echo -e "\n`currect_time_stamp` Restarting kadmin"
#	service kadmin restart
}

setup_kdc|tee -a $LOC/kdc-setup.log

#End of Script
