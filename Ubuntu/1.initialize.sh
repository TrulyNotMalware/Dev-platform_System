#!/bin/zsh

# Load Service Settings
source ../envs.sh

# Install NFS
sudo apt-get install -y nfs-common nfs-kernel-server firewalld

# Only For Master Nodes.
# Create shared docker image directories.

# sudo firewall-cmd --permanent --add-service=nfs
# sudo firewall-cmd --reload
#
# sudo mkdir -p /images
# sudo chown ${users}:${users} /images
# sudo cat << EOF | sudo tee /etc/exportfs
# /images/ *(rw,sync,no_subtree_check,no_root_squash)
# EOF
#
# sudo exportfs -v

# Swap-off
sudo swapoff -a
sudo sed -i "s/^.*swap.*$/#\0/" /etc/fstab
sudo modprobe rbd

# Insert Nets
echo "net.bridge.bridge-nf-call-ip6tables = 1" | sudo tee -a /etc/sysctl.d/k8s.conf
echo "net.bridge.bridge-nf-call-iptables = 1" | sudo tee -a /etc/sysctl.d/k8s.conf
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.d/k8s.conf

# Apply
sudo sysctl --system

# install Docker.
sudo apt-get update

sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
# Add gpg key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Check archi
ARCH=`arch`
AARCH64="aarch64"

# For Bash
#if [ ${ARCH} == ${AARCH64} ]; then
if [ ${ARCH} = ${AARCH64} ]; then
        ARCH="arm64"
        echo "aarch64 changed to arm64"
else
        echo "Arch is $ARCH"
        fi


echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io

sudo sed -i "s/DOCKER_DATA_ROOT_PATH/${DOCKER_DATA_ROOT_PATH}/g" setups/daemon.json
sudo cp ./setups/daemon.json /etc/docker/
sudo systemctl restart docker
sudo usermod -aG docker $(users)

# install k8s
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt-get update
sudo apt-get install -y kubelet=1.18.19-00 kubeadm=1.18.19-00 kubectl=1.18.19-00

