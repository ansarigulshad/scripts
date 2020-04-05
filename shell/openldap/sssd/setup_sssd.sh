#!/usr/bin/env bash

#################################################################
# Script to setup sssd on centos/RHEL server                    ##
# Script will set variable from openldap.properties file        ##
#Author - Gulshad Ansari		                                    ##
#Email: gulshad.ansari@hotmail.com                     	        ##
#LinkedIn : https://www.linkedin.com/in/gulshad/       	        ##
#################################################################

yum clean all -y
yum install sssd authconfig -y
chkconfig sssd on
#systemctl enable sssd

LOC=`pwd`
OPENLDAP_PROPETIES=openldap.properties
source $LOC/$OPENLDAP_PROPETIES

#---- create sssd.conf file
cat > /etc/sssd/sssd.conf <<EOFILE
[sssd]
services = nss, pam 
# Which SSSD services are started.
# A separate process for each service is started

#debug_level = 9
# The amount of detail in the logs. Uncomment this and adjust as needed.
# Level 9 is the most detailed level available.

domains = tylersguides
# A list of domains to check when a client makes a request. They are
# checked in the oder listed. The domains listed must have a matching
# configuration section in the format [domain/domainname]

[pam]
# The verbosity of output and logging related to PAM requests. Uncomment
# and adjust as needed. As with the main section, 9 is maximum verbosity.
#pam_verbosity = 9
#debug_level = 9

[domain/tylersguides]
cache_credentials = true
# This enables or disables credential caching. I.e. after successfully
# authenticating a user, the credentials will be stored locally. If the 
# domain is unavailable, users will still be able to login using the 
# cached information.

#account_cache_expiration = 0
# By default, the credential cache never expires. If you want sssd to 
# remove cached credentials, this option will cause them to expire 
# after the number of days it is set to.

#debug_level = 9
# The verbosity of this domains log file.

id_provider = ldap
# SSSD can resolve user information from a number of different sources
# such as LDAP, local files, and Active Directory. This option sets
# the domain's source of identity information. 

#auth_provider = ldap
# As with identity providers, SSSD can authenticate in a variety of ways.
# By default, SSSD will use the value of id_provider.

access_provider = ldap
# The access provider controls the source for determining who is allowed
# to access the system. Even if a user successfully authenticates, if they
# don't meet the criteria provider by the access provider, they will be
# denied access.

ldap_access_order = filter
ldap_access_filter = (objectClass=posixAccount)
# These define the criteria the access provider uses to control who
# is allowed to login. In this case, any user that matches the 
# LDAP filter in this example will be allowed access. Any entry
# that has an objectClass of posixAccount will be allowed access.

ldap_uri = ${ARG_LDAPURI}
# The URI(s) of the directory server(s) used by this domain.

ldap_search_base = ${ARG_DOMAINCONTROLLER}
# The LDAP search base you want SSSD to use when looking
# for entries. There are options for search bases for various types
# of searches, such as users. Read the sssd-ldap man page for details.

# ldap_tls_cacert = /pki/cacerts.pem
# The file containing CA certificates you want sssd to trust.

# ldap_tls_cipher_suite = HIGH
# The TLS ciphers you wish to use. SSSD uses OpenSSL style cipher
# suites

ldap_default_bind_dn = ${ARG_BINDDN}
# The DN used to search your directory with. It must have read access to
# everything your system needs.

ldap_default_authtok = ${ARG_L_ADMINPASSWORD}
# The password of the bind DN.

ldap_tls_reqcert = demand
# This defines how sssd will handle server certificates. Demand means
# that we are requiring the host portion of the URI to match the
# certificate's subject or an SAN, the current time is within the valid
# times on the certificate, and that it's signing chain ends with a CA
# in the file defined by ldap_tls_cacert.
EOFILE

chown root:root /etc/sssd/sssd.conf
chmod 600 /etc/sssd/sssd.conf

echo "session required pam_mkhomedir.so skel=/etc/skel/ umask=0022" >> /etc/pam.d/sshd

systemctl restart sssd

authconfig --enablesssdauth --enablesssd --updateall

# End of script

### Verify
# ssh <user>@localhost
# Next Step: 1) Install packages on all other nodes 2) copy /etc/sshd/sssd.conf & /etc/pam.d/sshd files to other nodes
# 3) Start sssd
