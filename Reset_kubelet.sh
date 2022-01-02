#!/bin/bash

#check is Root?
#==============
if (( $EUID != 0 )); then
    echo "This script must be run as root"
    exit
fi

echo ""
echo "================"
echo "Reset Kubelet..."
echo "================"
#Stop Kubelet


systemctl stop kubelet
kubeadm reset
rm -rf /var/lib/kubelet
