#!/bin/bash
#
#
# Ref: https://community.hortonworks.com/questions/19204/do-we-have-any-script-which-we-can-use-to-clean-tm.html
# 
usage="Usage: dir_diff.sh [days]"
hdfsPath=/ranger/audit/hdfs
if [ ! "$1" ]
then
  echo $usage
  exit 1
fi

now=$(date +%s)
hadoop fs -ls $hdfsPath | grep "^d" | while read f; do
dir_date=`echo $f | awk '{print $6}'`
difference=$(( ( $now - $(date -d "$dir_date" +%s) ) / (24 * 60 * 60 ) ))
  if [ $difference -gt $1 ]; 
  then
    hadoop fs -ls `echo $f| awk '{ print $8 }'`;
    
    # replace above ls command with below rm command to remove data.
    # hadoop fs -rm -r `echo $f| awk '{ print $8 }'`;
  fi
done

