#!/bin/bash

#EFK 구축을 위한 shell scripts.
ELASTIC_STORAGE_SIZE="10Gi"
ELASTIC_PORT=9200
ELASTIC_ROOT_LOG_LEVEL=info
ELASTIC_NODE_PORT=30920
KIBANA_CONTAINER_PORT=5601
KIBANA_NODE_PORTS=30050

NAME_SPACE="dev-project"

STORAGE_CLASS_NAME="nfs-storageclass"
template_location="yamls/template/"

#Pull images - 5.6버전을 사용한다.
docker pull elasticsearch:5.6-alpine
docker pull kibana:5.6
############################################################################
#If Redhat,
docker pull fluent/fluentd-kubernetes-daemonset:elasticsearch

#If Debian
#docker pull fluent/fluentd-kubernetes-daemonset:v1.3.0-debian-elasticsearch
############################################################################

#Elastic search yamls
sed -e "s/ELASTIC_STORAGE_SIZE/${ELASTIC_STORAGE_SIZE}/g" < ${template_location}/elastic-search-template.yaml > yamls/created/elastic-search.yaml
sed -i "s/ELASTIC_PORT$/${ELASTIC_PORT}/g" yamls/created/elastic-search.yaml
sed -i "s/ELASTIC_NODE_PORT$/${ELASTIC_NODE_PORT}/g" yamls/created/elastic-search.yaml
sed -i "s/ELASTIC_ROOT_LOG_LEVEL/${ELASTIC_ROOT_LOG_LEVEL}/g" yamls/created/elastic-search.yaml
sed -i "s/STORAGE_CLASS_NAME/${STORAGE_CLASS_NAME}/g" yamls/created/elastic-search.yaml
sed -i "s/NAME_SPACE/${NAME_SPACE}/g" yamls/created/elastic-search.yaml
#Kibana yamls
sed -e "s/KIBANA_CONTAINER_PORT/${KIBANA_CONTAINER_PORT}/g" <${template_location}/kibana-template.yaml > yamls/created/kibana.yaml
sed -i "s/KIBANA_NODE_PORTS/${KIBANA_NODE_PORTS}/g" yamls/created/kibana.yaml
sed -i "s/ELASTIC_PORT/${ELASTIC_PORT}/g" yamls/created/kibana.yaml
sed -i "s/NAME_SPACE/${NAME_SPACE}/g" yamls/created/kibana.yaml
#Fluentd yamls
sed -e "s/ELASTIC_PORT/${ELASTIC_PORT}/g" <${template_location}/fluentd-template.yaml > yamls/created/fluentd.yaml
sed -i "s/NAME_SPACE/${NAME_SPACE}/g" yamls/created/fluentd.yaml
sed -e "s/NAME_SPACE/${NAME_SPACE}/g" <${template_location}/fluentd-configmap-template.yaml > yamls/created/fluentd-configmap.yaml

kubectl apply -f yamls/created/elastic-search.yaml
kubectl apply -f yamls/created/kibana.yaml
kubectl apply -f yamls/created/fluentd.yaml
kubectl apply -f yamls/created/fluentd-configmap.yaml
