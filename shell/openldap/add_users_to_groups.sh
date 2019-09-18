#!/bin/bash

#################################################################
# Script to add users to group              ##
#
#                                                              ##
#                                                              ##
#Author - Gulshad Ansari                                       ##
#Email: gulshad.ansari@hotmail.com                             ##
#LinkedIn : https://www.linkedin.com/in/gulshad/               ##
#################################################################

# groups and user mapping
# hd-admins (gulshad, adnan, magdum, amir, atul)
# hd-developers (ajay, raghav, umesh, joy, john, jason, peter)
# appusers (lisa, ammy, prity, priyanka)
# marketing (zareen,kiran)
# sales (giby,jackson)
# testing (salman)
# hd-operations (zoya)
# hd-engineering (keshav)

LOC=`pwd`
OPENLDAP_PROPETIES=openldap.properties
source $LOC/$OPENLDAP_PROPETIES

# mkdir groupmembers

#for thisgroup in `cat groups.list`
#do
#cat > groupmembers/$thisgroup"-members".ldif <<EOFILE

cat > $LOC/add_user_to_group.ldif <<EOFILE
dn: CN=hd-admins,${ARG_GROUP_BASE}
changetype: modify
add: memberuid
memberuid: gulshad
memberuid: adnan
memberuid: magdum
memberuid: amir
memberuid: atul

dn: cn=hd-developers,${ARG_GROUP_BASE}
changetype: modify
add: memberuid
memberuid: ajay
memberuid: raghav
memberuid: umesh
memberuid: joy
memberuid: john
memberuid: jason
memberuid: peter

dn: cn=appusers,${ARG_GROUP_BASE}
changetype: modify
add: memberuid
memberuid: lisa
memberuid: ammy
memberuid: prity
memberuid: priyanka

dn: cn=marketing,${ARG_GROUP_BASE}
changetype: modify
add: memberuid
memberuid: zareen
memberuid: kiran

dn: cn=sales,${ARG_GROUP_BASE}
changetype: modify
add: memberuid
memberuid: giby
memberuid: jackson

dn: cn=testing,${ARG_GROUP_BASE}
changetype: modify
add: memberuid
memberuid: salman

dn: cn=hd-operations,${ARG_GROUP_BASE}
changetype: modify
add: memberuid
memberuid: zoya

dn: cn=hd-engineering,${ARG_GROUP_BASE}
changetype: modify
add: memberuid
memberuid: keshav
EOFILE
#done


ldapmodify -x -D "${ARG_BINDDN}" -w "${ARG_L_ADMINPASSWORD}" -f $LOC/add_user_to_group.ldif

# End of script
