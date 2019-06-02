#!/bin/bash

#################################################################
# Script to create user group membership ldif file             ##
# files will be stored under `groupmembers` directory          ##
# members list should me added manually to all ldif file       ##
#                                                              ##
#                                                              ##
#Author - Gulshad Ansari                                       ##
#Email: gulshad.ansari@hotmail.com                             ##
#LinkedIn : https://www.linkedin.com/in/gulshad/               ##
#################################################################

LOC=`pwd`
AD_PROPETIES=ad.properties
source $LOC/$AD_PROPETIES

mkdir groupmembers

for thisgroup in `cat groups.list`
do 
# touch groupmembers/$thisgroup"-members".list
cat > groupmembers/$thisgroup"-members".ldif <<EOFILE
dn: CN=$thisgroup,$ARG_GROUP_BASE
changetype: modify
add: member
member: CN=Gulshad Ansari,$ARG_USER_BASE
member: CN=Adnan Khan,$ARG_USER_BASE
member: CN=Amir Shaikh,$ARG_USER_BASE
EOFILE
done



