#!/bin/bash  

yum install openssl
openssl genrsa -out ca.key 8192
openssl req -new -x509 -days 1826 -extensions v3_ca -key ca.key -out ca.crt -subj "/C=US/ST=California/L=Palo Alto/O=Cloudera/OU=Consulting/CN=Root CA"

mkdir -p -m 0700 /etc/pki/CA/{certs,crl,newcerts,private}
mv ca.key /etc/pki/CA/private;mv ca.crt /etc/pki/CA/certs
touch /etc/pki/CA/index.txt; echo 1000 > /etc/pki/CA/serial
chmod 0400 /etc/pki/CA/private/ca.key



