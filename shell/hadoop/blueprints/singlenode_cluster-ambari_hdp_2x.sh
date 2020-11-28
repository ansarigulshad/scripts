#!/bin/bash
#
#
##########################################################################################################
#Script Name	 : singlenode_cluster-ambari_hdp_2x.sh
#Description	 : This Script is developed to quickly deploy a single node HDP cluster using default values
#Author        : Gulshad Ansari
#LinkedIn      : https://linkedin.com/in/gulshad/
#
#
#Note
#
#
# 
##########################################################################################################
#
#
#
#
#

echo "========DOWNLOAD AMBARI-REPO========================"
wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.6.2.2/ambari.repo -O /etc/yum.repos.d/ambari.repo
yum clean all

echo "========INSTALL & SETUP AMBARI-SERVER========================"
yum install ambari-server -y
ambari-server setup -s
ambari-server start

echo "========INSTALL & SETUP AMBARI-AGENT========================"
yum install ambari-agent -y
ambari-agent reset $(hostname -f)
ambari-agent start

curl -u admin:admin http://$(hostname -f):8080/api/v1/hosts

echo "========PREPARE AND DEPLOY CLUSTER========================"
cat > /var/tmp/cluster_configuration.json<<EOF
{
  "host_groups" : [
    {
      "name" : "my_host_group",     
      "components" : [
        {
          "name" : "NAMENODE"
        },
        {
          "name" : "SECONDARY_NAMENODE"
        },       
        {
          "name" : "DATANODE"
        },
        {
          "name" : "HDFS_CLIENT"
        },
        {
          "name" : "RESOURCEMANAGER"
        },
        {
          "name" : "NODEMANAGER"
        },
        {
          "name" : "YARN_CLIENT"
        },
        {
          "name" : "HISTORYSERVER"
        },
        {
          "name" : "APP_TIMELINE_SERVER"
        },
        {
          "name" : "MAPREDUCE2_CLIENT"
        },
        {
          "name" : "ZOOKEEPER_SERVER"
        },
        {
          "name" : "ZOOKEEPER_CLIENT"
        }
      ],
      "cardinality" : "1"
    }
  ],
  "Blueprints" : {
    "blueprint_name" : "single-node-hwx-cluster",
    "stack_name" : "HDP",
    "stack_version" : "2.6"
  }
}
EOF

cat > /var/tmp/hostmapping.json << EOF 
{
  "blueprint" : "single-node-hwx-cluster",
  "host_groups" :[
    {
      "name" : "my_host_group", 
      "hosts" : [         
        {
          "fqdn" : "$(hostname -f)"
        }
      ]
    }
  ]
}
EOF

curl -u admin:admin -i -H 'X-Requested-By: ambari' -X POST -d @/var/tmp/cluster_configuration.json http://$(hostname -f):8080/api/v1/blueprints/single-node-hwx-cluster

curl -H "X-Requested-By: ambari" -X POST -u admin:admin http://$(hostname -f):8080/api/v1/clusters/clustername -d @/var/tmp/hostmapping.json

echo "Login to Ambari UI and check the progress : http://<ambarihostname>:8080"

#done


