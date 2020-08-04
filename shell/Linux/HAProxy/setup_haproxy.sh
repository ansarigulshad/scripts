#!/bin/bash

_SERVICE_URL1=http://172.25.38.64:30800
_SERVICE_URL2=http://172.25.60.40:30800

cd /usr/local
wget https://archive.apache.org/dist/httpd/httpd-2.4.16.tar.gz
wget https://archive.apache.org/dist/apr/apr-1.5.2.tar.gz 
wget https://archive.apache.org/dist/apr/apr-util-1.5.4.tar.gz

tar -xvf httpd-2.4.16.tar.gz
tar -xvf apr-1.5.2.tar.gz 
tar -xvf apr-util-1.5.4.tar.gz

mv apr-1.5.2/ apr
mv apr httpd-2.4.16/srclib/ 
mv apr-util-1.5.4/ apr-util
mv apr-util httpd-2.4.16/srclib/

yum clean all
yum install pcre pcre-devel -y
yum install gcc -y

cd /usr/local/httpd-2.4.16
./configure

make
make install

/usr/local/apache2/bin/apachectl start

curl localhost

_STATUS=$?
if [ $_STATUS != 0 ]
	then
		echo 'Setup not completed successfully'
    exit 0
	else
		echo 'Setup completed Successfully'
fi

cd /usr/local/apache2/conf
cp httpd.conf httpd.conf.backup

for i in proxy_module proxy_http_module proxy_ajp_module proxy_balancer_module slotmem_shm_module lbmethod_byrequests_module lbmethod_bytraffic_module lbmethod_bybusyness_module
do
echo "Coniguring $i Module"
sed -i "/${i}/s/^#//" httpd.conf
done

sed -i "/ServerAdmin/s/^/#/g" httpd.conf

for i in proxy_module proxy_http_module proxy_ajp_module proxy_balancer_module slotmem_shm_module lbmethod_byrequests_module lbmethod_bytraffic_module lbmethod_bybusyness_module ServerAdmin
do
grep $i httpd.conf
done


echo "Include conf/my-service.conf" >> httpd.conf

cat > /usr/local/apache2/conf/my-service.conf <<EOFILE
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# This is the Apache server configuration file providing SSL support.
# It contains the configuration directives to instruct the server how to
# serve pages over an https connection. For detailing information about these
# directives see <URL:http://httpd.apache.org/docs/2.2/mod/mod_ssl.html>
#
# Do NOT simply read the instructions in here without understanding
# what they do.  They're here only as hints or reminders.  If you are unsure
# consult the online docs. You have been warned.

#Listen 80
<VirtualHost *:80>
        ProxyRequests off
        ProxyPreserveHost on

        Header add Set-Cookie "ROUTEID=.%{BALANCER_WORKER_ROUTE}e; path=/" env=BALANCER_ROUTE_CHANGED

        <Proxy balancer://mycluster>
                BalancerMember $_SERVICE_URL1 loadfactor=1 route=1
                BalancerMember $_SERVICE_URL2 loadfactor=1 route=2

                Order Deny,Allow
                Deny from none
                Allow from all

                ProxySet lbmethod=byrequests scolonpathdelim=On stickysession=ROUTEID maxattempts=1 failonstatus=500,501,502,503 nofailover=Off
        </Proxy>

        # balancer-manager
        # This tool is built into the mod_proxy_balancer
        # module and will allow you to do some simple
        # modifications to the balanced group via a gui
        # web interface.
        <Location /balancer-manager>
                SetHandler balancer-manager
                Order deny,allow
                Allow from all
        </Location>


       ProxyPass /balancer-manager !
       ProxyPass / balancer://mycluster/
       ProxyPassReverse / balancer://mycluster/

</VirtualHost>

EOFILE

/usr/local/apache2/bin/apachectl restart

#end
