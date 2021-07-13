#!/bin/bash

getOS(){
source /etc/os-release
case "$ID" in
  ubuntu) 
  echo 'ubuntu';;
  rhel) 
  echo 'rhel';;
  *) echo 'Could not determind OS version'
  exit 1
  ;;
esac
}


echo "Starting the script"
HOST_OS="$(getOS)"

echo My OS is ${HOST_OS}
