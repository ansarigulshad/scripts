#!/bin/bash
#
#
##########################################################################################################
#Script Name	 : find_top_files_and_directories_on_hdfs.sh
#Description	 : This Script is developed to find out top N number of files & directoriers in HDFS
#Author        : Gulshad Ansari
#LinkedIn      : https://linkedin.com/in/gulshad/
#
#
#Usage:
#   sh find_top_files_and_directories_on_hdfs.sh [HDFS Directory Path] [top N file/dir]
#Example:
#   sh find_top_files_and_directories_on_hdfs.sh /hdfs/path 10
##########################################################################################################
#
#
#
#
#

dir=$1
topN=$2
outputFile=`echo "/var/tmp/hdfs_Top"$topN"_Files.out"`
outputDir=`echo "/var/tmp/hdfs_Top"$topN"_Directories.out"`
usage="Usage: ./find_top_files_and_directories_on_hdfs.sh [HDFS Directory Path] [top N file/dir]\n\nExample: ./find_top_files_and_directories_on_hdfs.sh /hdfs/path 10\n"

if [ $# != 2 ]
then
  echo -e "\nNot enough parameters passed"
  echo -e $usage
  exit 1
elif [[ ! $dir =~ [/] ]]
then
  echo -e "\nInvalid HDFS path, $dir"
  echo -e $usage
  exit 1
elif [[ ! $topN =~ ^[0-9]+$ ]]
then
  echo -e "\nNon-numeric characters in 2nd argument, $topN"
  echo -e $usage
  exit 1
fi


echo -e "Please wait while we calculate size and determine top $topN directories & files in $dir"

#top N Files
for flist in `hadoop fs -ls -R $1 | grep "^-"  | awk '{print $8}'`;do hadoop fs -du $flist 2>/dev/null;done | sort -nk1 | tail -$topN > $outputFile

#top N Directories
for dlist in `hadoop fs -ls -R $1 | grep "^d" | awk '{print $8}'`;do hadoop fs -du -s $dlist 2>/dev/null;done | sort -nk1 | tail -$topN > $outputDir

echo -e "\n\n\nOutput is saved in below files"
echo -e "\nTop $topN files : $outputFile"
echo -e "Top $topN Directories : $outputDir\n\n"

echo -e "========================================================================================================="

echo -e "File Size(Bytes) \t File Path\n" ; cat $outputFile | awk '{print $1 " " $2}' | sed -e 's/ /\t\t\t/g'

echo -e "========================================================================================================="

echo -e "Dir Size(Bytes) \t Directory Path\n" ; cat $outputDir | awk '{print $1 " " $2}' | sed -e 's/ /\t\t\t/g'
