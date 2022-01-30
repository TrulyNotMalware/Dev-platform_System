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


