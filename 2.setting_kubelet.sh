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

users=`who | awk '{print $1}'`

echo "==========================="
echo "Create Weavenet Objects..."
echo "==========================="
#Weavenet.
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

echo ""
echo "=============================="
echo "Remove taints in master nodes."
echo "=============================="

#Remove Taints. ( beacuase only use 1 nodes. )
kubectl taint node ${node_name} node-role.kubernetes.io/master:NoSchedule-

namespace="dev-project"
echo ""
echo "==================================================="
echo "Create base Namespace ${namespace} & change context"
echo "==================================================="

#create Namespace.
kubectl create -f yamls/namespace.yaml

sed -i'' -r -e "/contexts:/a\\
- context:\n\
    cluster: kubernetes\n\
    user: kubernetes-admin\n\
    namespace: ${namespace}\n\
  name: ${namespace}\
" /home/${users}/.kube/config

sed -i "s/^current-context: kubernetes-admin@kubernetes$/current-context: ${namespace}/" /home/${users}/.kube/config

