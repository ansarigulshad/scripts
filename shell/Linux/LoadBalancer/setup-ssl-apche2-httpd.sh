#!/bin/bash

# PRE-REQUISITES : Setup Apache2 HTTPD


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# - Generate SSL Cert and Key:
openssl req -new -newkey rsa:2048 -x509 -sha256 -days 365 -nodes -out /usr/local/apache2/conf/server.crt -keyout /usr/local/apache2/conf/server.key -subj "/C=US/ST=North Carolina/L=Raleigh/O=CLDR/OU=Support/CN=$(hostname -f)"

# - Install mod_ssl package
yum install mod_ssl -y

# - Copy mode_ssl.so to /usr/local/apache2/modules/
cp /usr/lib64/httpd/modules/mod_ssl.so ../modules/

# - Add mod_ssl module to httpd.conf
sed -i '/^#LoadModule rewrite_module/a LoadModule ssl_module modules/mod_ssl.so'  /usr/local/apache2/conf/httpd.conf

# - Uncomment "Include conf/extra/httpd-ssl.conf" from httpd.conf
sed -i '/^#.*httpd-ssl.conf/s/^#//' /usr/local/apache2/conf/httpd.conf

# - Create httpd-ssl.conf
cat > /usr/local/apache2/conf/httpd-ssl.conf <<EOFILE 
Listen 443

SSLCipherSuite HIGH:MEDIUM:!MD5:!RC4
SSLProxyCipherSuite HIGH:MEDIUM:!MD5:!RC4
SSLHonorCipherOrder on
SSLProtocol all -SSLv3
SSLProxyProtocol all -SSLv3
SSLPassPhraseDialog  builtin
SSLSessionCacheTimeout  300

<VirtualHost *:443>
DocumentRoot "/usr/local/apache2/htdocs"
ServerName `hostname -f`
ServerAdmin you@example.com
ErrorLog "/usr/local/apache2/logs/error_log"
TransferLog "/usr/local/apache2/logs/access_log"

SSLEngine on
SSLCertificateFile "/usr/local/apache2/conf/server.crt"
SSLCertificateKeyFile "/usr/local/apache2/conf/server.key"

<FilesMatch "\.(cgi|shtml|phtml|php)$">
    SSLOptions +StdEnvVars
</FilesMatch>
<Directory "/usr/local/apache2/cgi-bin">
    SSLOptions +StdEnvVars
</Directory>

BrowserMatch "MSIE [2-5]" \
         nokeepalive ssl-unclean-shutdown \
         downgrade-1.0 force-response-1.0

CustomLog "/usr/local/apache2/logs/ssl_request_log" \
          "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \"%r\" %b"
</VirtualHost>
EOFILE


# - Restart apache httpd
/usr/local/apache2/bin/apachectl restart


curl -vvv -k https://localhost

# End
