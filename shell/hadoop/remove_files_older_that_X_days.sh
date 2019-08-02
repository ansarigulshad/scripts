#!/bin/bash
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
    # write your remove commands here
    hadoop fs -ls `echo $f| awk '{ print $8 }'`;
  fi
done

