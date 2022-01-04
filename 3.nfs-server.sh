#!/bin/bash

#check is Root?
#==============
if (( $EUID != 0 )); then
        echo "PASS"
else
        echo "DO NOT RUN AS ROOT"
        exit
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

