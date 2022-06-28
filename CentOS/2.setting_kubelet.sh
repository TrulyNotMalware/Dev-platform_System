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
#node_name="master"
node_name=`hostname`

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

##############################################################
sed -i'' -r -e "/contexts:/a\\
- context:\n\
    cluster: kubernetes\n\
    user: kubernetes-admin\n\
    namespace: ${namespace}\n\
  name: ${namespace}\
" /home/${users}/.kube/config

sed -i "s/^current-context: kubernetes-admin@kubernetes$/current-context: ${namespace}/" /home/${users}/.kube/config

echo "================================================"
echo "Create ConfigMap in yamls/created/configmap.yaml"
echo "================================================"
config_template_location="yamls/templates/configmap-template.yaml"
ip_addr=`hostname -I| awk '{print $1}'`
certificateAuthorityData=$(grep -r 'certificate-authority-data:' ~/.kube/config | awk '{ print $2 }')
clientCertificateData=$(grep -r 'client-certificate-data:' ~/.kube/config | awk '{ print $2 }')
clientKeyData=$(grep -r 'client-key-data:' ~/.kube/config | awk '{ print $2 }')

#create create-dir & Copy.
mkdir yamls/created
cp ${config_template_location} yamls/created/configmap.yaml

sed -i "s/certificate-authority-data:$/certificate-authority-data: ${certificateAuthorityData}/g" yamls/created/configmap.yaml
sed -i "s/client-certificate-data:$/client-certificate-data: ${clientCertificateData}/g" yamls/created/configmap.yaml
sed -i "s/client-key-data:$/client-key-data: ${clientKeyData}/g" yamls/created/configmap.yaml
sed -i "s/USER_NAME$/${users}/g" yamls/created/configmap.yaml
sed -i "s/NAME_SPACE$/${namespace}/g" yamls/created/configmap.yaml
sed -i "s/IP_ADDR:6443$/${ip_addr}:6443/g" yamls/created/configmap.yaml

#Apply files.
kubectl create -f yamls/created/configmap.yaml
#Check
kubectl get cm -A | grep ${users}
##############################################################

#0210 Try more easy way to build.
kubectl config set-context ${namespace} --namespace=${namespace} --cluster=kubernetes --user=kubernetes-admin

#Apply
kubectl config use-context ${namespace}

#install k9s
echo ""
echo "==============="
echo "Install k9s...."
echo "==============="
curl -sS https://webinstall.dev/k9s | bash

echo ""
echo "========="
echo "Finished."
echo "========="
