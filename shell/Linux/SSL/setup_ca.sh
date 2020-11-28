#!/bin/bash  

yum install openssl
openssl genrsa -out ca.key 8192
openssl req -new -x509 -days 1826 -extensions v3_ca -key ca.key -out ca.crt -subj "/C=US/ST=California/L=Palo Alto/O=Cloudera/OU=Consulting/CN=Root CA"

mkdir -p -m 0700 /etc/pki/CA/{certs,crl,newcerts,private}
mv ca.key /etc/pki/CA/private;mv ca.crt /etc/pki/CA/certs
touch /etc/pki/CA/index.txt; echo 1000 > /etc/pki/CA/serial
chmod 0400 /etc/pki/CA/private/ca.key


#optional
cat > /etc/ssl/myopenssl.cnf<<EOFILE
[ ca ]
default_ca = CA_default

[ CA_default ]
# Directory and file locations.
dir               = /etc/pki/CA
certs             = /etc/pki/CA/certs
crl_dir           = /etc/pki/CA/crl
new_certs_dir     = /etc/pki/CA/newcerts
database          = /etc/pki/CA/index.txt
serial            = /etc/pki/CA/serial
RANDFILE          = /etc/pki/CA/private/.rand

# The root key and root certificate.
private_key       = /etc/pki/CA/private/ca.key.pem
certificate       = /etc/pki/CA/certs/ca.cert.pem

# For certificate revocation lists.
crlnumber         = $dir/crlnumber
crl               = $dir/crl/ca.crl.pem
crl_extensions    = crl_ext
default_crl_days  = 30

# SHA-1 is deprecated, so use SHA-2 instead.
default_md        = sha256
name_opt          = ca_default
cert_opt          = ca_default
default_days      = 375
preserve          = no
policy            = policy_strict


[ policy_strict ]
# The root CA should only sign intermediate certificates that match.
countryName             = match
stateOrProvinceName     = match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional


[ policy_loose ]
# Allow the intermediate CA to sign a more diverse range of certificates.
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
default_bits        = 2048
distinguished_name  = req_distinguished_name
string_mask         = utf8only

# SHA-1 is deprecated, so use SHA-2 instead.
default_md          = sha256

# Extension to add when the -x509 option is used.
x509_extensions     = v3_ca

[ req_distinguished_name ]
# See <https://en.wikipedia.org/wiki/Certificate_signing_request>.
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name
localityName                    = Locality Name
organizationName                = Organization Name
organizationalUnitName          = Organizational Unit Name
commonName                      = Common Name
emailAddress                    = Email Address

# EDIT THESE: Default values for consistency and less typing.
# Variable name                     Value
#------------------------           ------------------------------
countryName_default                 = GB
stateOrProvinceName_default         = London
localityName_default                = London
organizationName_default            = Cloudera, Inc
organizationalUnitName_default      = Support
commonName_default                  = Root CA
emailAddress_default                = support@cloudera.com

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ v3_intermediate_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ usr_cert ]
basicConstraints = CA:FALSE
nsCertType = client, email
nsComment = "OpenSSL Generated Client Certificate”l
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection

[ server_cert ]
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "OpenSSL Generated Server Certificate using intermediate CA"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[ crl_ext ]
authorityKeyIdentifier=keyid:always


[ ocsp ]
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, OCSPSigning
EOFILE

