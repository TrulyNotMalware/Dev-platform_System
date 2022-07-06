#!/bin/zsh

# Change Kubernetes Container runtime docker -> containerd

NODE_NAME=`hostname`
CONTEXT=`sudo cat /var/lib/kubelet/kubeadm-flags.env`
INSECURE_REGISTRY="http://test.insecure.registry"

# Stop kubelet & Docker
sudo kubectl drain ${NODE_NAME} --force --ignore-daemonsets --delete-local-data

# Checking.
kubectl get node -o wide

sudo systemctl stop kubelet
sudo systemctl stop docker

# [Optional] Delete docker
# sudo apt-get purge -y docker-ce docker-ce-cli
# sudo apt-get autoremove -y docker-ce docker-ce-cli
# sudo rm -rf /var/lib/docker /etc/docker
# sudo groupdel docker
# sudo rm -rf /var/run/docker.sock
# sudo rm -rf /etc/docker
# sudo rm -rf ~/.docker

# Redhat
# sudo yum remove docker-ce docker-ce-cli

# Change containerd settings.
sudo sed -i "s/disabled_plugins/#disabled_plugins/g" /etc/containerd/config.toml
sudo systemctl restart containerd

sudo echo -e -n "${CONTEXT} --container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock" > /var/lib/kubelet/kubeadm-flags.env

# Restart Kubelet
sudo systemctl start kubelet
sudo kubectl uncordon ${NODE_NAME}

# Change node annotation dockershim -> containerd
kubectl annotate node/${NODE_NAME} kubeadm.alpha.kubernetes.io/cri-socket
kubectl annotate node/${NODE_NAME} kubeadm.alpha.kubernetes.io/cri-socket=unix:///run/containerd/containerd.sock

# If you are using Insecure repository then,
cat <<EOF | sudo tee /etc/containerd/config.toml
[plugins.cri.registry]
[plugins.cri.registry.mirrors]
[plugins.cri.registry.mirrors."docker.io"]
  endpoint = ["https://mirror.gcr.io","https://registry-1.docker.io"]
[plugins.cri.registry.mirrors."${INSECURE_REGISTRY}"]
  endpoint = ["${INSECURE_REGISTRY}"]
[plugins.cri.registry.configs."${INSECURE_REGISTRY}".tls]
  insecure_skip_verify = true
EOF
sudo systemctl restart containerd

