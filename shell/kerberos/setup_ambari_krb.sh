#!/bin/bash

########################################
#Script to setup and configure MIT KDC##
#Author - Gulshad Ansari			  ##
########################################

LOC=`pwd`
KRB_PROPERTIES=krb.properties
source $LOC/$KRB_PROPERTIES


currect_time_stamp()
{
	echo "`date +%Y-%m-%d" "%H:%M:%S`"
}


create_payload()
{
	if [ "$1" == "service" ]
	then

		echo "[
  {
    \"Clusters\": {
      \"desired_config\": {
        \"type\": \"krb5-conf\",
        \"tag\": \"version1\",
        \"properties\": {
          \"domains\":\"\",
          \"manage_krb5_conf\": \"true\",
          \"conf_dir\":\"/etc\",
	  \"content\" : \"[libdefaults]\n  renew_lifetime = 7d\n  forwardable= true\n  default_realm = {{realm|upper()}}\n  ticket_lifetime = 24h\n  dns_lookup_realm = false\n  dns_lookup_kdc = false\n  #default_tgs_enctypes = {{encryption_types}}\n  #default_tkt_enctypes ={{encryption_types}}\n\n{% if domains %}\n[domain_realm]\n{% for domain in domains.split(',') %}\n  {{domain}} = {{realm|upper()}}\n{% endfor %}\n{%endif %}\n\n[logging]\n  default = FILE:/var/log/krb5kdc.log\nadmin_server = FILE:/var/log/kadmind.log\n  kdc = FILE:/var/log/krb5kdc.log\n\n[realms]\n  {{realm}} = {\n    admin_server = {{admin_server_host|default(kdc_host, True)}}\n    kdc = {{kdc_host}}\n }\n\n{# Append additional realm declarations below #}\n\"
        }
      }
    }
  },
  {
    \"Clusters\": {
      \"desired_config\": {
        \"type\": \"kerberos-env\",
        \"tag\": \"version1\",
        \"properties\": {
          \"kdc_type\": \"mit-kdc\",
          \"manage_identities\": \"true\",
          \"install_packages\": \"true\",
          \"encryption_types\": \"aes des3-cbc-sha1 rc4 des-cbc-md5\",
          \"realm\" : \"$REALM\",
          \"kdc_hosts\" : \"$KDC_HOST\",
          \"kdc_host\" : \"$KDC_HOST\",
          \"admin_server_host\" : \"$KDC_HOST\",
          \"executable_search_paths\" : \"/usr/bin, /usr/kerberos/bin, /usr/sbin, /usr/lib/mit/bin, /usr/lib/mit/sbin\",
          \"password_length\": \"20\",
          \"password_min_lowercase_letters\": \"1\",
          \"password_min_uppercase_letters\": \"1\",
          \"password_min_digits\": \"1\",
          \"password_min_punctuation\": \"1\",
          \"password_min_whitespace\": \"0\",
          \"service_check_principal_name\" : \"${cluster_name}-${short_date}\",
          \"case_insensitive_username_rules\" : \"false\"
        }
      }
    }
  }
]" > $LOC/payload

	elif [ "$1" == credentials ]
	then
		echo "{
  \"session_attributes\" : {
    \"kerberos_admin\" : {
      \"principal\" : \"admin/admin\",
      \"password\" : \"$KRB_ADMIN_PASSWD\"
    }
  },
  \"Clusters\": {
    \"security_type\" : \"KERBEROS\"
  }
}" > $LOC/payload
	fi
}

configure_kerberos()
{
	#Add Kerberos Service to Cluster
	echo -e "\n`currect_time_stamp` Adding KERBEROS Service to cluster"
	curl -H "X-Requested-By:ambari" -u $AMBARI_ADMIN_USER:$AMBARI_ADMIN_PASSWORD -i -X POST http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/KERBEROS
	
	#Add Kerberos client
	echo -e "\n`currect_time_stamp` Adding KERBEROS_CLIENT component to the KERBEROS service"
	sleep 1
	curl -H "X-Requested-By:ambari" -u $AMBARI_ADMIN_USER:$AMBARI_ADMIN_PASSWORD -i -X POST http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/KERBEROS/components/KERBEROS_CLIENT

	#Create Payload Service
	create_payload service
	sleep 1
	curl -H "X-Requested-By:ambari" -u $AMBARI_ADMIN_USER:$AMBARI_ADMIN_PASSWORD -i -X PUT -d @"$LOC"/payload http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME

	#Add Kerberos client component to each host
	echo -e "\n `currect_time_stamp` Creating the KERBEROS_CLIENT host components for each host"
		for client in `echo $KERBEROS_CLIENTS|tr ',' ' '`;
		do
			curl -H "X-Requested-By:ambari" -u $AMBARI_ADMIN_USER:$AMBARI_ADMIN_PASSWORD -i -X POST -d '{"host_components" : [{"HostRoles" : {"component_name":"KERBEROS_CLIENT"}}]}' http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/hosts?Hosts/host_name=$client
			sleep 1
		done

	#Install Kerberos Service & components
	echo -e "\n`currect_time_stamp` Installing the KERBEROS service and components"
	curl -H "X-Requested-By:ambari" -u $AMBARI_ADMIN_USER:$AMBARI_ADMIN_PASSWORD -i -X PUT -d '{"ServiceInfo": {"state" : "INSTALLED"}}' http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/KERBEROS
	echo -e "\n`currect_time_stamp` Sleeping for 1 minute"
	sleep 60

	#Stop All Services & Enable Kerberos
	echo -e "\n`currect_time_stamp` Stopping all the services"
	curl -H "X-Requested-By:ambari" -u $AMBARI_ADMIN_USER:$AMBARI_ADMIN_PASSWORD -i -X PUT -d '{"RequestInfo":{"context":"Stop all services-Dabster"},"Body":{"ServiceInfo": {"state" : "INSTALLED"}}}' http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services
    echo -e "\n`currect_time_stamp` Sleeping for 3 minutes"
	sleep 180
	if [[ "${AMBARI_VERSION:0:3}" > "2.7" ]] || [[ "${AMBARI_VERSION:0:3}" == "2.7" ]]
        then
                echo -e "\n`currect_time_stamp` Uploading Kerberos Credentials"
                curl -H "X-Requested-By:ambari" -u $AMBARI_ADMIN_USER:$AMBARI_ADMIN_PASSWORD -i -X POST -d '{ "Credential" : { "principal" : "admin/admin@'$REALM'", "key" : "hadoop", "type" : "temporary" }}' http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/credentials/kdc.admin.credential
                sleep 1
    fi
	echo -e "\n`currect_time_stamp` Enabling Kerberos"
	create_payload credentials
	curl -H "X-Requested-By:ambari" -u $AMBARI_ADMIN_USER:$AMBARI_ADMIN_PASSWORD -i -X PUT -d @$LOC/payload http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME

	#Start All Services
	echo -e "\n`currect_time_stamp` Starting all services after 2 minutes..Please be patient :)"
	sleep 120
	curl -H "X-Requested-By:ambari" -u $AMBARI_ADMIN_USER:$AMBARI_ADMIN_PASSWORD -i -X PUT -d '{"RequestInfo":{"context":"Start all services-Dabster"},"Body":{"ServiceInfo": {"state" : "STARTED"}}}' http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services
	echo -e "\n`currect_time_stamp` Please check Ambari UI\nThank You! :)"
}

configure_kerberos|tee -a $LOC/kerberos-auto-setup.log


#End of Script

