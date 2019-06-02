#!/bin/bash

#################################################################
# Script to Add Users in Active Directory                      ##
# Script will take inputs from users.list file                 ##
# Users wil be added under OU specied in ad.properties file    ##
#                                                     	       ##
#Author - Gulshad Ansari		                       ##
#Email: gulshad.ansari@hotmail.com                     	       ##
#LinkedIn : https://www.linkedin.com/in/gulshad/       	       ##
#################################################################

LOC=`pwd`
AD_PROPETIES=ad.properties
source $LOC/$AD_PROPETIES

create_ad_users()
{
FIRSTNAME="$1"
LASTNAME="$2"

# Create User LDIF File
cat > /tmp/$FIRSTNAME.ldif <<EOFILE
dn: CN=$FIRSTNAME $LASTNAME,${ARG_USER_BASE}
changetype: add
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
cn: $FIRSTNAME $LASTNAME
sn: $FIRSTNAME$LASTNAME
givenName: $FIRSTNAME
displayName: $FIRSTNAME $LASTNAME
name: $FIRSTNAME $LASTNAME
accountExpires: 9223372036854775807
userAccountControl: 514
sAMAccountName: $FIRSTNAME$LASTNAME
userPrincipalName: $FIRSTNAME$LASTNAME@${ARG_DOMAIN}

dn: CN=$FIRSTNAME $LASTNAME,${ARG_USER_BASE}
changetype: modify
replace: unicodePwd
unicodePwd::${ARG_NewUserPass}

dn: CN=$FIRSTNAME $LASTNAME,${ARG_USER_BASE}
changetype: modify
replace: userAccountControl
userAccountControl: 512
EOFILE

# Add User
LDAPTLS_REQCERT=never ldapadd -x -H "${ARG_LDAPURI}" -a -D "${ARG_BINDDN}" -f /tmp/$FIRSTNAME.ldif -w "${ARG_USERPSWD}"

}


while read LINE
do
        echo "Creating user: " $LINE
        create_ad_users $LINE
        if [ $? -eq 0 ]; then
                echo "User" $LINE "Added Successfully"
	else
		echo "Could not add User" $LINE "..."
        fi
done < $LOC/users.list


