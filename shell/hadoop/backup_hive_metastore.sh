#!/usr/bin/env bash

#
#Script Name	 : backup_hive_metastore.sh
#Description	 : This Script is developed to take backup of hive metastore and keep latest 7 days backup files
#Author        : Gulshad Ansari
#LinkedIn      : https://linkedin.com/in/gulshad/
#
#
#email="username@example.com"
metastoreHost=mysqldserver.example.com
tsNow=$(date "+%F-%H")
tsLast=$(date "+%F-%H" --date='1 hour ago')
targetDir=/backup/hadoop/hive
snapNow=$targetDir/hiveMetastore-backup-$tsNow.sql.gz
snapLast=$targetDir/hiveMetastore-backup-$tsLast.sql.gz
snapSizeThresh=3
user=user
pass=password
dbName=hive


function checkforTarget () {
   if [ ! -d $targetDir ]; then
      echo "$(date) Target directory ($targetDir) is missing."
      exit 1
   fi
}

function removeOldSnapshots () {
#   find $targetDir/hiveMetastore* -type f -mtime +7 -exec echo "$(date) deleting backup: " {}  \;
   find $targetDir/hiveMetastore* -type f -mtime +7 -exec rm {}  \;
}

function getSnapshot () {
   mysqldump -C -h $metastoreHost  -u $user -p$pass $dbName | gzip > $snapNow
#   echo "Hive metastore backup completed succesfully"
}

function sendReport () {
#   echo -e "message" | /bin/mail -s "subject" $email
}

# Action starts here!
checkforTarget
getSnapshot
removeOldSnapshots
sendReport
