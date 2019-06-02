#!/bin/bash

#################################################################
# Script to Add Users in Groups                      ##
# Script will take inputs from groups.list file                ##
# Groups wil be added under OU specied in ad.properties file   ##
# This script does not add any users in groups                 ##
#                                                              ##
#Author - Gulshad Ansari                                       ##
#Email: gulshad.ansari@hotmail.com                             ##
#LinkedIn : https://www.linkedin.com/in/gulshad/               ##
#################################################################

LOC=`pwd`
AD_PROPETIES=ad.properties
source $LOC/$AD_PROPETIES

mkdir groupmembers



create_ad_groups()
{
GROUPNAME="$1"

# Add users to group
LDAPTLS_REQCERT=never ldapadd -x -H "${ARG_LDAPURI}" -a -D "${ARG_BINDDN}" -f /tmp/$GROUPNAME"-members".ldif -w "${ARG_USERPSWD}"

}


while read LINE
do
        echo "Updating Group membership for: " $LINE
        create_ad_groups $LINE | tee -a adduserstogroups.out
        if [ $? -eq 0 ]; then
                echo -e  "\n Membership for Group" $LINE " Updated Successfully"
        else
                echo -e  "\n Could not update Group membership for " $LINE "..."
        fi
done < $LOC/groups.list



for thisgroup in `cat groups.list`
do 
touch groupmembers/$thisgroup"-members".list
cat > groupmembers/$thisgroup"-members".ldif <<EOFILE
dn: CN=$GROUPNAME,$ARG_GROUP_BASE
changetype: modify
add: member
member: CN=Gulshad Ansari,$ARG_USER_BASE
member: CN=Adnan Khan,$ARG_USER_BASE
EOFILE
done



