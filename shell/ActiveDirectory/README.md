# Add Users and groups in Active Directory using shell script

## 1. Download script
```
# yum install git -y
# git clone https://github.com/ansarigulshad/scripts.git

# cd scripts/shell/ActiveDirectory/

# chmod +x *.sh
```
## 2. Update ad.properties file as per your AD environment details
```
cat ad.properties

# replace EXAMPLE.COM with your AD DOMAIN
# sed -i.bkp 's/EXAMPLE/ADDOMAIN/g' ad.properties

# Replace ldap server hostname with your ad server hostname
# sed -i 's/adserver.hortonworks.com/new.adserver.fqdn/g' ad.properties
```

## 3. Add users
####  3.1. Add users in users.list file
####  3.2. Execute addUsers.sh
```
$ ./addUsers.sh
```

## 4. Add Groups
####  4.1. Add groups in groups.list file
####  4.2. Execute addGroups.sh
```
$ ./addGroups.sh
```
## 5. Add Users to Group
#### This is 2 part script
#### 5.1. Create ldif files for each group membership
```
$ ./addUsersToGroups-Part-I-CreateGroupMembershipfiles.sh
```
_This script will create groupmembershif ldif file under `groupmembers` directory_
_kindly add appropriate members in each ldif file before executing Part-II script_

#### 5.2. Execute `Part-II` command to update user-group membership i.e. add users to group
```
$ ./addUsersToGroups-Part-II-AddUsersinGroup.sh
```

