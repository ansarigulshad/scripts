#!/bin/#!/usr/bin/env bash

#################################################################
# Script to Add Users in Active Directory                      ##
# Script will take inputs from users.list file.                ##
# Make sure groups.list file is available in same location      ##
# Users wil be added under OU specied in openlap.properties    ##
#                                                     	       ##
#Author - Gulshad Ansari		                       ##
#Email: gulshad.ansari@hotmail.com                     	       ##
#LinkedIn : https://www.linkedin.com/in/gulshad/       	       ##
#################################################################

LOC=`pwd`
OPENLDAP_PROPETIES=openldap.properties
source $LOC/$OPENLDAP_PROPETIES
gidCounter=665

currect_time_stamp()
{
        echo "`date +%Y-%m-%d" "%H:%M:%S`"
}


create_ad_groups()
{
GROUPNAME="$1"
gidCounter=$((gidCounter+1))   #not working as expected

# Create Group LDIF File
cat > /tmp/$GROUPNAME.ldif <<EOFILE
dn: CN=$GROUPNAME,${ARG_GROUP_BASE}
objectClass: top
objectClass: posixGroup
gidNumber: $gidCounter
EOFILE

echo -e "\n`currect_time_stamp` " >> addgroups.out
# Add group in OU $ARG_GROUP_BASE
LDAPTLS_REQCERT=never ldapadd -x -H "${ARG_LDAPURI}" -a -D "${ARG_BINDDN}" -f /tmp/$GROUPNAME.ldif -w "${ARG_L_ADMINPASSWORD}"

}


while read LINE
do
        echo "Creating Groups: " $LINE
        create_ad_groups $LINE | tee -a addgroups.out
        if [ $? -eq 0 ]; then
                echo "Group" $LINE "Added Successfully"
	else
		echo "Could not add Group " $LINE "..."
        fi
done < $LOC/groups.list
