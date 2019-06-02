#!/bin/bash


###############################################################
# Setup Prerequisites for Hadoop Cluster - DABSTERInc		  #
# This script is tested on RHEL/CentOs 7					  #
#															  #
# This script will perform below pre-req		  			  #	
# 1) Disable Firewall		  								  #	
# 2) Install and Start NTP		  							  #
# 3) Disable SELinux 		  								  #
# 4) Set Swappiness to 10		  							  #
# 5) Enable THP		  										  #
###############################################################


# Run this script with root user


STATUS_FIREWALL=$(systemctl show -p ActiveState firewalld | cut -d'=' -f2)
STATUS_NTP=$(systemctl show -p ActiveState ntpd | cut -d'=' -f2)

function StartNTP() {
	echo 'Starting NTP Service......'
	systemctl  start ntpd
	systemctl  status ntpd
	sleep 3
	echo 'NTP Started successfully'
}

function StopFirewall() {
	echo 'Disabling firewalld.....'
	systemctl  stop firewalld
	systemctl  status firewalld	
	systemctl disable firewalld 
	sleep 3
	echo 'Firewall successfully'
}

function DisableSELinux(){
	setenforce 0
	sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config && cat /etc/selinux/config
	echo 'SE Status has been changed to permissive. It will be changed to disabled automatically after reboot'
}


# FIREWALL
if [ $STATUS_FIREWALL != 'active' ]
	then
		echo 'Firewall is not Active, hence no need to stop'
	else
		echo 'stopping firewall' #StopFirewall
		StopFirewall
fi


# NTP Service
if [ $(systemctl list-unit-files | grep -w 'ntpd.service' | wc -l) -eq 0 ]
	then
		echo 'Installing ntp service'
		yum install ntp -y
		StartNTP
	elif [ $STATUS_NTP != 'active' ]
		then
		echo 'NTP is not Active, Starting the Service now....'
		StartNTP
	else
		StartNTP
fi



#SELINUX
echo 'Disabling SELinux....'
DisableSELinux

sleep 3

# SWAPPINESS
echo 'Setting vm.swappiness value to 10'
sysctl vm.swappiness=10
echo 'vm.swappiness=10' >> /etc/sysctl.conf


sleep 1 

# THP
echo 'Configuring Transparent Huge Pages'
echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled
echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag


sleep 1 

echo 'Prerequisite Has been completed successfully'
