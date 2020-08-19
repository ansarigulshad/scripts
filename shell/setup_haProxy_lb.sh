#!/bin/bash

############################################################################################################################
# Script - Setup HAProxy LoadBalancer on centos/rhel
############################################################################################################################
# Note:
#    - Run this script as a 'root' user
#    - Make sure 'openssl' is installed
#    - 
#
# Feel free to provide feedback or improvement ideas 
# LinkedIn : https://www.linkedin.com/in/gulshad/
# email : gulshad.ansari@hotmail.com
# 
############################################################################################################################



LOC=`pwd`
# _SVC_PROPERTIES=service.properties
# source $LOC/$_SVC_PROPERTIES

_SERVER_1_HOSTNAME="c3230-node1.coelab.cloudera.com"
_SERVER_1_PORT=8443
_SERVER_2_HOSTNAME="c3230-node2.coelab.cloudera.com"
_SERVER_2_PORT=8443

install_required_Packages() {
    yum clean all
    yum install haproxy -y
    if [ "$?" != "0" ]; then
        echo  "Could not install required packages, kinldy contact your system admin to resolve the issue and try again"
        exit 0;
    fi
}

start_ha_proxy_service() {
    systemctl enable haproxy
    systemctl restart haproxy
}

generate_ssl_certificates() {
    openssl genrsa -out /etc/haproxy/haproxy.key 2048
    openssl req -new -key /etc/haproxy/haproxy.key -out /etc/haproxy/haproxy.csr -subj "/C=US/ST=North Carolina/L=Raleigh/O=Cloudera/OU=Support/CN=$(hostname -f)"
    openssl x509 -req -days 365 -in /etc/haproxy/haproxy.csr -signkey /etc/haproxy/haproxy.key -out /etc/haproxy/haproxy.crt
    cat /etc/haproxy/haproxy.key /etc/haproxy/haproxy.crt > /etc/haproxy/haproxy.pem
}

backup_ha_proxy_cfg_file() {
    mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.orig
    if [ "$?" == "0" ]; then
        echo -e "Backed up '/etc/haproxy/haproxy.cfg' successfully"
    else
        echo -e "Could not create backup of original haproxy.cfg file"
    fi
    
}

configure_ha_proxy_cfg_file() {
    cat > /etc/haproxy/haproxy.cfg <<EOFILE
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    log         127.0.0.1 local2     #Log configuration
 
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000                
    user        haproxy             #Haproxy running under user and group "haproxy"
    group       haproxy
    daemon
 
    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats
 
#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000
 
#---------------------------------------------------------------------
#HAProxy Monitoring Config
#---------------------------------------------------------------------
listen haproxy3-monitoring *:8090                #Haproxy Monitoring run on port 8090
    mode http
    option forwardfor
    option httpclose
    stats enable
    stats show-legends
    stats refresh 5s
    stats uri /stats                             #URL for HAProxy monitoring
    stats realm Haproxy\ Statistics
    stats auth gulshad:gulshad            #User and Password for login to the monitoring dashboard
    stats admin if TRUE
    default_backend app-main                    #This is optionally for monitoring backend
 
#---------------------------------------------------------------------
# FrontEnd Configuration
#---------------------------------------------------------------------
frontend main
    bind *:80  # comment this out if you want to block http connection on LB
    bind *:443 ssl crt /etc/haproxy/haproxy.pem
    option http-server-close
    option forwardfor
    default_backend app-main
 
#---------------------------------------------------------------------
# BackEnd roundrobin as balance algorithm
#---------------------------------------------------------------------
backend app-main
    mode http
    balance roundrobin
    cookie SERVERID insert indirect nocache
    http-request set-header X-Forwarded-Port %[dst_port]
    http-request add-header X-Forwarded-Proto https if { ssl_fc }
#    server c3230-node1 c3230-node1.coelab.cloudera.com:30800 check    #if end-service is not secured with https
    server server1 $_SERVER_1_HOSTNAME:$_SERVER_1_PORT ssl verify none cookie server1
    server server2 $_SERVER_2_HOSTNAME:$_SERVER_2_PORT ssl verify none cookie server2
EOFILE
}

install_required_Packages | tee -a $LOC/haproxy-setup.log
generate_ssl_certificates | tee -a $LOC/haproxy-setup.log
backup_ha_proxy_cfg_file | tee -a $LOC/haproxy-setup.log
configure_ha_proxy_cfg_file | tee -a $LOC/haproxy-setup.log
start_ha_proxy_service | tee -a $LOC/haproxy-setup.log

if [ "$?" == "0" ]; then
    echo -e 'HAProxy setup had been completed Successfully!!!'
    exit 0;
fi
#End of Script


