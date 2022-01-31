#!/bin/bash

#check is Root?
#==============
if (( $EUID != 0 )); then
        echo "SUDO NEED."
	exit
else
	echo "PASS"
fi

#Start nfs-server
echo ""
echo "=================="
echo "start nfs-server.."
echo "=================="

systemctl enable nfs-server && systemctl start nfs-server
#check.
systemctl status nfs-server
users=`who | awk '{print $1}'`

#Create sharing directory to /nfs.
mkdir /nfs
chown ${users}:${users} /nfs
#Insert NFS- exports

cat << EOF | tee -a /etc/exports
#NFS-SERVICE-DIRECTORY
/nfs/ *(rw,sync,no_root_squash)
EOF

#Apply
exportfs -r

echo ""
echo "======================================"
echo "NFS-mount dir : ${users}:${users} /nfs"
echo "======================================"
#Check
showmount -e

#If you use slave nodes, then mount /nfs to slave.

echo ""
echo "======================================="
echo "Create nfs serviceAccount & Provisioner"
echo "======================================="

template_location="yamls/template/"
nfs_template="nfs-template.yaml"
storage_template="storage-class-template.yaml"
name_space="dev-project"
storage_class_name="nfs-storageclass"

#Copy & replace namespace.
cp ${template_location}${nfs_template} yamls/created/nfs-sa.yaml
sed -i "s/NAME_SPACE$/${name_space}/g" yamls/created/nfs-sa.yaml

#Apply
#kubectl apply -f yamls/created/nfs-sa.yaml

#Create Storage class for dynamic provisioning.
cp ${template_location}${storage_template} yamls/created/storage-class.yaml
sed -i "s/CLASS_NAME$/${storage_class_name}/g" yamls/created/storage-class.yaml

#Apply
#kubectl apply -f yamls/create/storage-class.yaml

