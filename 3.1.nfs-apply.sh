#!/bin/bash

template_location="yamls/templates/"
nfs_template="nfs-provisioner-template.yaml"
nfs_sa_template="nfs-sa-template.yaml"
storage_template="storage-class-template.yaml"
name_space="dev-project"
storage_class_name="nfs-storageclass"

nfs_template_server="{nfs_server}"
nfs_template_path="{nfs_path}"

#nfs shared directory.
nfs_path="\/nfs"

IP_ADDR=`hostname -I| awk '{print $1}'`

docker_image="quay.io/external_storage/nfs-client-provisioner:v3.1.0-k8s1.11"

echo "================================================================================"
echo "Load docker image ${docker_image}"
echo "================================================================================"

docker pull ${docker_image}

#[FIXME] Node label adding is wired.... not working
#########################################################################
node_name=`kubectl get node -o wide | grep ${IP_ADDR} | awk '{print $1}'`
label_name="dev-pjt-master=true"
echo ${node_name}

echo ""
echo "============================================"
echo "Add labels in ${node_name} - ${label_name}"
echo "============================================"

kubectl label nodes ${node_name} ${label_name}
#Check
kubectl get nodes --show-labels | grep ${label_name}

#########################################################################
echo ""
echo "======================================="
echo "Create nfs serviceAccount & Provisioner"
echo "======================================="


#Copy sa
cp ${template_location}${nfs_sa_template} yamls/created/nfs-sa.yaml
sed -i "s/NAME_SPACE/${name_space}/g" yamls/created/nfs-sa.yaml

#Apply
kubectl apply -f yamls/created/nfs-sa.yaml
echo "================================================================================"
kubectl get serviceaccount -A | grep nfs
echo "================================================================================"

#Create deployment
#cp ${template_location}${nfs_template} yamls/created/nfs-provisioner.yaml

sed -e "s/${nfs_template_server}/${IP_ADDR}/g" < ./${template_location}${nfs_template} > yamls/created/nfs-provisioner.yaml
sed -i "s/${nfs_template_path}$/${nfs_path}/g" yamls/created/nfs-provisioner.yaml

#Apply
kubectl apply -f yamls/created/nfs-provisioner.yaml
echo "================================================================================"
kubectl get deployment -A | grep nfs
echo "================================================================================"


#Create Storage class for dynamic provisioning.
cp ${template_location}${storage_template} yamls/created/storage-class.yaml
sed -i "s/CLASS_NAME$/${storage_class_name}/g" yamls/created/storage-class.yaml

#Apply
kubectl apply -f yamls/created/storage-class.yaml
echo "================================================================================"
kubectl get storageclass -A | grep nfs
echo "================================================================================"
