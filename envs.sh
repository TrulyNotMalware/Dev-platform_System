#!/bin/bash


users=`who | awk '{print $1}'`
user=`whoami`

IP_ADDR=`hostname -I| awk '{print $1}'`
ip_addr=`hostname -I| awk '{print $1}'`
POD_NET="10.32.0.0/12"
SERVICE_NET="10.96.0.0/12"


node_name=`hostname`
namespace="dev-project"
name_space="dev-project"

node_name=`kubectl get node -o wide | grep ${IP_ADDR} | awk '{print $1}'`
label_name="dev-pjt-master=true"

template_location="yamls/templates/"
mariadb_root_pwd="devproject"
mariadb_user_name="devs"
mariadb_pwd="devproject"
mariadb_replication_pwd="devproject"
mariadb_node_port=30006
storage_size="10Gi"
