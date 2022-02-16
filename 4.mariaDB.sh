#!/bin/bash

#=============
#check is Root?
#==============
if (( $EUID != 0 )); then
        echo "PASS"
else
        echo "DO NOT RUN AS ROOT"
        exit
fi

echo ""
echo "==================================="
echo "Pull maraidb-images from docker hub"
echo "         Tags : 10.3.32"
echo "==================================="

docker pull mariadb:10.3.32
docker pull bitnami/mariadb:10.3.32-debian-10-r85
#docker pull docker.io/bitnami/mariadb:10.5.8-debian-10-r69
docker pull docker.io/bitnami/minideb:buster


mariadb_root_pwd="devproject"
mariadb_user_name="devs"
mariadb_pwd="devproject"
mariadb_replication_pwd="devproject"
echo ""
echo "=================================================="
echo "Create Secret in yamls/created/maraidb-secret.yaml"
echo "Mariadb root pwd : ${mariadb_root_pwd}, Mariadb pwd : ${mariadb_pwd}"
echo "=================================================="

template_location="yamls/templates/"
secret="mariadb-secret-template.yaml"
name_space="dev-project"

cp ${template_location}${secret} yamls/created/mariadb-secret.yaml

sed -i "s/MARIA_DB_ROOT_PWD/$(echo ${mariadb_root_pwd}|base64| tr -d '\n')/g" yamls/created/mariadb-secret.yaml
sed -i "s/MARIA_DB_PWD/$(echo ${mariadb_pwd}|base64|tr -d '\n')/g" yamls/created/mariadb-secret.yaml
sed -i "s/MARIA_DB_REPLICATION_PWD/$(echo ${mariadb_replication_pwd}|base64|tr -d '\n')/g" yamls/created/mariadb-secret.yaml
sed -i "s/NAME_SPACE$/${name_space}/g" yamls/created/mariadb-secret.yaml


#Apply
kubectl apply -f yamls/created/mariadb-secret.yaml

#Check
echo "===================================================="
kubectl get secret
echo "===================================================="

storage_size="8Gi"
#Create pvc
sed -e "s/STORAGE_SIZE/${storage_size}/g" < ${template_location}/mariadb-pvc-template.yaml > yamls/created/mariadb-pvc.yaml

#Apply
kubectl apply -f yamls/created/mariadb-pvc.yaml

#Check
echo "===================================================="
kubectl get pvc -A | grep mariadb
echo "===================================================="

#Create mariadb-cluster
mariadb_node_port=30006

sed -e "s/NAME_SPACE/${name_space}/g" < ${template_location}/mariadb-template.yaml > yamls/created/mariadb.yaml
sed -i "s/NODE_PORT/${mariadb_node_port}/g" yamls/created/mariadb.yaml
sed -i "s/MARIA_DB_USER_NAME/${mariadb_user_name}/g" yamls/created/mariadb.yaml

#Apply
kubectl apply -f yamls/created/mariadb.yaml

#Check
echo "===================================================="
kubectl get pod -A |grep mariadb
echo "===================================================="



