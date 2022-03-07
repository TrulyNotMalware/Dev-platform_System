#!/bin/bash

#EFK 구축을 위한 shell scripts.
ELASTIC_STORAGE_SIZE="10Gi"
ELASTIC_PORT=9200
ELASTIC_ROOT_LOG_LEVEL=info
KIBANA_CONTAINER_PORT=5601
KIBANA_NODE_PORTS=30050

STORAGE_CLASS_NAME="nfs-storageclass"
template_location="yamls/templates/"

#Pull images
docker pull elasticsearch:5.6-alpine
docker pull kibana:5.6
docker pull fluent/fluentd-kubernetes-daemonset:elasticsearch

echo "###############"
echo "Create yamls..."
echo "###############"

sed -e "s/ELASTIC_STORAGE_SIZE/${ELASTIC_STORAGE_SIZE}/g" < ${template_location}/elastic-search-template.yaml > yamls/created/elastic-search.yaml
sed -i "s/ELASTIC_PORT$/${ELASTIC_PORT}/g" yamls/created/elastic-search.yaml
sed -i "s/ELASTIC_ROOT_LOG_LEVEL/${ELASTIC_ROOT_LOG_LEVEL}/g" yamls/created/elastic-search.yaml
sed -i "s/STORAGE_CLASS_NAME/${STORAGE_CLASS_NAME}/g" yamls/created/elastic-search.yaml

sed -e "s/KIBANA_CONTAINER_PORT/${KIBANA_CONTAINER_PORT}/g" <${template_location}/kibana-template.yaml > yamls/created/kibana.yaml
sed -i "s/KIBANA_NODE_PORTS/${KIBANA_NODE_PORTS}/g" yamls/created/kibana.yaml
sed -i "s/ELASTIC_PORT/${ELASTIC_PORT}/g" yamls/created/kibana.yaml

sed -e "s/ELASTIC_PORT/${ELASTIC_PORT}/g" <${template_location}/fluentd-template.yaml > yamls/created/fluentd.yaml


#Applys
kubectl apply -f yamls/created/elastic-search.yaml
kubectl apply -f yamls/created/kibana.yaml
kubectl apply -f yamls/created/fluentd.yaml
