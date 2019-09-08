#!/bin/bash

#################################################################
# Script to Add Users in Active Directory                      ##
# Script will take inputs from users.list file.                ##
# Make sure users.list file is available in same location      ##
# Users wil be added under OU specied in openlap.properties    ##
#                                                     	       ##
#Author - Gulshad Ansari		                       ##
#Email: gulshad.ansari@hotmail.com                     	       ##
#LinkedIn : https://www.linkedin.com/in/gulshad/       	       ##
#################################################################

LOC=`pwd`
OPENLDAP_PROPETIES=openldap.properties
source $LOC/$OPENLDAP_PROPETIES
uidCounter=9999

currect_time_stamp()
{
        echo "`date +%Y-%m-%d" "%H:%M:%S`"
}

create_ad_users()
{
UNAME="$1"
uidCounter=$((uidCounter+1))     # doen't work as expected
#FIRSTNAME="$1"
# LASTNAME="$2"

# Create User LDIF File
cat > /tmp/$UNAME.ldif <<EOFILE

dn: uid=$UNAME,${ARG_USER_BASE}
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
cn: $UNAME
uid: $UNAME
uidNumber: $uidCounter
gidNumber: 665
homeDirectory: /home/$UNAME
loginShell: /bin/bash
gecos: $UNAME
userPassword: {crypt}x
shadowLastChange: 17058
shadowMin: 0
shadowMax: 99999
shadowWarning: 7
EOFILE

echo -e "\n`currect_time_stamp` " >> addusers.out

# Add User
LDAPTLS_REQCERT=never ldapadd -x -H "${ARG_LDAPURI}" -a -D "${ARG_BINDDN}" -f /tmp/$UNAME.ldif -w "${ARG_L_ADMINPASSWORD}"

# Create default password (Welcome123)
ldappasswd -s Welcome123 -D "${ARG_BINDDN}" -x "uid=$UNAME,${ARG_USER_BASE}" -w "${ARG_L_ADMINPASSWORD}"

}


while read LINE
do
        echo "Creating user: " $LINE
        create_ad_users $LINE | tee -a addusers.out
        if [ $? -eq 0 ]; then
                echo "User" $LINE "Added Successfully"
	else
		echo "Could not add User" $LINE "..."
        fi
done < $LOC/users.list
