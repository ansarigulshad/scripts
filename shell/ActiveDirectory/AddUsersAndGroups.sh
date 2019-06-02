#!/bin/bash

########################################
#Script to setup and configure MIT KDC##
#Author - Gulshad Ansari			  ##
########################################

LOC=`pwd`
AD_PROPETIES=ad.properties
source $LOC/$AD_PROPETIES


creat_ad_users()
{
  FIRSTNAME="$1"
  LASTNAME="$2"

  cat > /tmp/$FIRSTNAME.ldif <<EOFILE
  dn: CN=$FIRSTNAME $LASTNAME,${ARG_SEARCHBASE}
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

  dn: CN=$FIRSTNAME $LASTNAME,${ARG_SEARCHBASE}
  changetype: modify
  replace: unicodePwd
  unicodePwd::${ARG_NewUserPass}

  dn: CN=$FIRSTNAME $LASTNAME,${ARG_SEARCHBASE}
  changetype: modify
  replace: userAccountControl
  userAccountControl: 512
  EOFILE
}


while read LINE
do
  echo "Creating user: " $LINE
	create_users $LINE
done < $LOC/users.list








