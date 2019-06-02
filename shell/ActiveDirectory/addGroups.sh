#!/bin/bash

#################################################################
#Script to Add Groups in Active Directory                      ##
# Script will take inputs from groups.list file                ##
# Groups wil be added under OU specied in ad.properties file   ##
# This script does not add any users in groups                 ##
#                                                     	       ##
#Author - Gulshad Ansari		       	               ##
#Email: gulshad.ansari@hotmail.com                     	       ##
#LinkedIn : https://www.linkedin.com/in/gulshad/       	       ##
#################################################################

LOC=`pwd`
AD_PROPETIES=ad.properties
source $LOC/$AD_PROPETIES

gidCounter=665

create_ad_groups()
{
GROUPNAME="$1"
gidCounter=$((gidCounter+1))

# Create Group LDIF File
cat > /tmp/$GROUPNAME.ldif <<EOFILE
dn: CN=$GROUPNAME,$ARG_GROUP_BASE
objectClass: top
objectClass: group
cn: $GROUPNAME
name: $GROUPNAME
distinguishedName: CN=$GROUPNAME,$ARG_GROUP_BASE
instanceType: 4
sAMAccountName: $GROUPNAME
gidNumber: $gidCounter
EOFILE

# Add group in OU $ARG_GROUP_BASE
LDAPTLS_REQCERT=never ldapadd -x -H "${ARG_LDAPURI}" -a -D "${ARG_BINDDN}" -f /tmp/$GROUPNAME.ldif -w "${ARG_USERPSWD}"

}


while read LINE
do
        echo "Creating Groups: " $LINE
        create_ad_groups $LINE
        if [ $? -eq 0 ]; then
                echo "Group" $LINE "Added Successfully"
	else
		echo "Could not add Group " $LINE "..."
        fi
done < $LOC/groups.list

