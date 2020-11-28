#!/bin/bash

# SET VARIABLES
JAVA_HOME='/usr/jdk64/jdk1.8.0_112/'
_COUNTRY=IN
_STATE=KR
_CITY=BLR
_ORGANIZATION="Cloudera, Inc"
_DEPARTMENT=SUPPORT
_CN=`hostname -f`
_SAN='DNS:hdpcdp-1.vpc.cloudera.com,IP:10.65.27.34,DNS:hdpcdp-2.vpc.cloudera.com,IP:10.65.17.115,DNS:hdpcdp-3.vpc.cloudera.com,IP:10.65.23.132,DNS:hdpcdp-4.vpc.cloudera.com,IP:10.65.29.53'

# 1) Create private key and CSR :
mkdir /var/tmp/SSL
openssl genrsa -out /var/tmp/SSL/$_CN.key 2048

# openssl req -new -sha256 -key /var/tmp/SSL/`hostname -f`.key -out /var/tmp/SSL/`hostname -f`.csr -subj "/C=$_COUNTRY/ST=$_STATE/L=$_CITY/O=$_ORGANIZATION/OU=$_DEPARTMENT/CN=$_CN"
# openssl req -new -sha256 -key /var/tmp/SSL/`hostname -f`.key -out /var/tmp/SSL/`hostname -f`.csr -subj "/C=$_COUNTRY/ST=$_STATE/L=$_CITY/O=$_ORGANIZATION/OU=$_DEPARTMENT/CN=$_CN" -reqexts SAN -config <(cat /etc/ssl/myopenssl.cnf <(printf "\n[SAN]\nsubjectAltName=$_SAN"))

openssl req -new -sha256 \
-key /var/tmp/SSL/$_CN.key \
-out /var/tmp/SSL/$_CN.csr \
-subj "/C=$_COUNTRY/ST=$_STATE/L=$_CITY/O=$_ORGANIZATION/OU=$_DEPARTMENT/CN=$_CN"

# openssl req -in $(hostname -f).csr -noout -text

# 2) Sign CSR from CA and generate CA signed certificate:
openssl x509 -req \
-days 365 \
-CAcreateserial \
-CA /etc/pki/CA/certs/ca.crt \
-CAkey /etc/pki/CA/private/ca.key \
-in /var/tmp/SSL/$_CN.csr \
-out /var/tmp/SSL/$_CN.crt \
-extfile <(printf "subjectAltName=$_SAN")

# openssl x509 -noout -text -in /var/tmp/SSL/$_CN.crt | less

#3) Create PKCS12 keystore and convert it to JKS
openssl pkcs12 -export \
-inkey /var/tmp/SSL/$_CN.key \
-in /var/tmp/SSL/$_CN.crt \
-certfile /etc/pki/CA/certs/ca.crt \
-out /var/tmp/SSL/$_CN.pfx \
-password pass:changeit \
-passin pass:changeit
# keytool -list -keystore $(hostname -f).pfx -storetype PKCS12 -v

#4) Convert pkcs12 to jks
$JAVA_HOME/bin/keytool -importkeystore \
-srckeystore /var/tmp/SSL/$_CN.pfx \
-destkeystore /var/tmp/SSL/$_CN.jks \
-srcstoretype PKCS12 \
-deststoretype JKS \
-srcstorepass changeit \
-deststorepass changeit \
-srckeypass changeit \
-destkeypass changeit \
-srcalias 1 \
-destalias $_DN \
-noprompt

echo "SSL certificate and keystore generated in /var/tmp/SSL dir"
ls -lrt /var/tmp/SSL/

#Done





