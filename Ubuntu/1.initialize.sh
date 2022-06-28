#!/bin/bash

# 로직 아직 미추가..

# Load Service Settings
source ../envs.sh

# Install NFS
sudo apt-get install -y nfs-common

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
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get install -y docker-ce docker-ce-cli cntainerd.io

sudo sed -i "s/DOCKER_DATA_ROOT_PATH/${DOCKER_DATA_ROOT_PATH}/g" setups/daemon.json
sudo cp ./setups/daemon.json /etc/docker

# install k8s
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt-get update
sudo apt-get install -y kubelet=1.18.19-00 kubeadm=1.18.19-00 kubectl=1.18.19-00

