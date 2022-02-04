#!/bin/bash

#check is Root?
#==============
if (( $EUID != 0 )); then
    echo "This script must be run as root"
    exit
fi

IP_ADDR=`hostname -I| awk '{print $1}'`
POD_NET="10.32.0.0/12"
SERVICE_NET="10.96.0.0/12"

echo "======================"
echo "Install Kubernetes...."
echo "======================"

#Install Kubernetes 1.18.19
yum install -y kubeadm-1.18.19-0.x86_64 kubectl-1.18.19-0.x86_64 kubelet-1.18.19-0.x86_64 --disableexcludes=kubernetes 
#if you want to install the latest version of kubelet, then use this commands.
#yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes


echo ""
echo "===================="
echo "Start kubelet......."
echo "===================="

systemctl enable kubelet && systemctl start kubelet

#health check.
kubelet_check_cmd=`systemctl status kubelet | grep "Active:"`
echo "${kubelet_check_cmd}"
check_str="(running)"
if [[ "${kubelet_check_cmd}" =~ "${check_str}" ]]; then
        echo ""
        echo "========================="
        echo "Successfully Run kubelet."
        echo "========================="
else
        echo ""
        echo "================================="
        echo "kubelet run failed. check errors."
        echo "================================="
        journalctl -xeu kubelet
        exit 100
        fi

echo ""
echo "==============================="
echo "Init Kubelet.... in ${IP_ADDR}."
echo "==============================="
#Init kubelet.
kubeadm config images pull
#[FIXME] Need to check node name is exactly same with hostname.
#2022/02/04 Update init commands.
#node_name=`kubectl get node -o wide | grep ${IP_ADDR} | awk '{print $1}'`
node_name=`hostname`
#sed -e "s/{NODE_NAME}/${node_name}/g" < yamls/template/kubernetes-init-template.yaml > yamls/created/init-config.yaml
#sed -i "s/{IP_ADDR}/${IP_ADDR}/g" yamls/created/init-config.yaml
#kubeadm init --config yamls/created/init-config.yaml --upload-certs --v=5 --ignore-preflight-errors=all
kubeadm init --apiserver-advertise-address "${IP_ADDR}" --node-name ${node_name} --pod-network-cidr "${POD_NET}" --service-cidr "${SERVICE_NET}"

users=`who | awk '{print $1}'`
#OR
#users=`whoami`
echo "=============================================="
echo "Copy config files into /home/${users}/.kube..."
echo "=============================================="


#Copy configs
mkdir /home/${users}/.kube

cp -i /etc/kubernetes/admin.conf /home/${users}/.kube/config

chown ${users}:${users} /home/${users}/.kube/config
chown ${users}:${users} /home/${users}/.kube

echo "==============="
echo "Init Finished!!"
echo "==============="
