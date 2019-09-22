#!/bin/bash

############################################################################################################################
# Script - Passwordless ssh
############################################################################################################################
# Prerequisites:
#
# 0) Install sshpass command :  $ sudo yum install sshpass -y
#
# 1) Create a file 'hosts.list' to store server FQDN's one per line
# Example: 
# $ cat hosts.list
# hadoop.master1.us-east1-b.c.x-plateau-236613.internal
# hadoop.master2.us-east1-b.c.x-plateau-236613.internal
# hadoop.dn1.us-east1-b.c.x-plateau-236613.internal
# hadoop.dn2.us-east1-b.c.x-plateau-236613.internal
# hadoop.dn3.us-east1-b.c.x-plateau-236613.internal
# 
# 2) Enable Password Authentication (Only if password login is disabled):-> Perform step [1] & [2] on all the nodes manually
# 
############################################################################################################################



SCRIPT_PATH=`pwd`
MyUsername=dabnew
MyPASSWORD="Hadoop@1"

sudo yum install sshpass -y


#[1]-----Allow Password Authentication-----------------------
# $ sudo sed -i  's/^PasswordAuthentication no.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config && sudo cat /etc/ssh/sshd_config | grep PasswordAuthentication
# $ sudo service sshd restart

#[2]----Change/Update Password-----------------------------
# Change Password to $MyPASSWORD if password is not set (skip the step if you do not want to change your password)
# su - $MyUsername
# $ echo -e "$MyPASSWORD\n$MyPASSWORD" | sudo passwd $MyUsername

#----------------------------------------------------------

#[3]----Create ssh Dir on all nodes------------------------
echo "creating .ssh directory"

for MyClusterHosts in `cat $SCRIPT_PATH"/hosts.list"`
do
	sshpass -p$MyPASSWORD ssh -o "StrictHostKeyChecking no" $MyClusterHosts "mkdir ~/.ssh;chmod 700 ~/.ssh"
done

#[4]---Generate ssh keys----------------------------------

SSHCOUNT=0
while [ $SSHCOUNT -eq 0 ]
do
	read -p 'Do you want to perform ssh-keygen (y/n)': SSHVAL

	if [ $SSHVAL = 'y' ]
		then
			ssh-keygen
			break
		elif [ $SSHVAL = 'n' ]
			then
				break
		elif [ $SSHVAL != 'n' || $SSHVAL != 'y' ]
			then
			echo 'Please enter correct value'
			continue
	fi
done

#[5]----Copy public key to authorized_keys---------------
echo "Copying public key to authorized_keys...."
cat ~/.ssh/id_rsa.pub  >> ~/.ssh/authorized_keys


#[6]----SCP auth key to other nodes----------------------
echo "Copying keys to all other nodes"
for MyClusterHosts in `cat $SCRIPT_PATH"/hosts.list"`
	do
		echo $MyClusterHosts
		sshpass -p$MyPASSWORD scp ~/.ssh/authorized_keys $MyClusterHosts:~/.ssh/

	done

echo "Password-less ssh has been setup successfully"

exit 0


#End of script
