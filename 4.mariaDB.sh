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
mariadb_user_name="devs"
mariadb_user_pwd="devproject"

echo ""
echo "=================================================="
echo "Create Secret in yamls/created/maraidb-secret.yaml"
echo "User_name : ${mariadb_user_name} / User password : ${mariadb_user_pwd}"
echo "=================================================="

template_location="yamls/templates/"
secret="mariadb-secret-template.yaml"

cp ${template_location}${secret} yamls/created/mariadb-secret.yaml

sed -i "s/DB_USER_NAME$/$(echo ${mariadb_user_name}|base64| tr -d '\n')/g" yamls/created/mariadb-secret.yaml
sed -i "s/DB_USER_PWD$/$(echo ${mariadb_user_pwd}|base64|tr -d '\n')/g" yamls/created/mariadb-secret.yaml

#Apply
#kubectl apply -f ${template_location}/mariadb-secret.yaml

#Check
#kubectl get secret

echo ""
echo "==================================="
echo "Pull maraidb-images from docker hub"
echo "         Tags : 10.3.32"
echo "==================================="

docker pull mariadb:10.3.32


