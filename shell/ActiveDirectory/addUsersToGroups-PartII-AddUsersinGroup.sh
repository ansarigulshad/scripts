#!/bin/bash

#################################################################
# Script to Add Users in Groups                                ##
# Script will take inputs from groupmembers/* file             ##
#                                                              ##
#Author - Gulshad Ansari                                       ##
#Email: gulshad.ansari@hotmail.com                             ##
#LinkedIn : https://www.linkedin.com/in/gulshad/               ##
#################################################################

LOC=`pwd`
AD_PROPETIES=ad.properties
source $LOC/$AD_PROPETIES


update_ad_groups()
{
GROUPNAME="$1"

# Add users to group
LDAPTLS_REQCERT=never ldapadd -x -H "${ARG_LDAPURI}" -a -D "${ARG_BINDDN}" -w "${ARG_USERPSWD}" -f $LOC/groupmembers/$GROUPNAME"-members".ldif

}


while read LINE
do
        echo "Updating Group membership for: " $LINE
        update_ad_groups $LINE | tee -a adduserstogroups.out
        if [ $? -eq 0 ]; then
                echo -e  "\n Membership for Group" $LINE " Updated Successfully"
        else
                echo -e  "\n Could not update Group membership for " $LINE "..."
        fi
done < $LOC/groups.list




