#!/bin/bash

#Test for firewalld

#All - Kubernetes API server
firewall-cmd --permanent --zone=public --add-port=6443/tcp

#etcd, kube-apiserver - clientAPI
firewall-cmd --permanent --zone=public --add-port=2379-2380/tcp

#Control plane - Kubelet API
firewall-cmd --permanent --zone=public --add-port=10250/tcp

#Self - kube-scheduler
firewall-cmd --permanent --zone=public --add-port=10251/tcp

#Self - kube-controller-manager
firewall-cmd --permanent --zone=public --add-port=10252/tcp

#Node port bounds
firewall-cmd --permanent --zone=public --add-port=30000-32767/tcp

#Reload firewall
firewall-cmd --reload
