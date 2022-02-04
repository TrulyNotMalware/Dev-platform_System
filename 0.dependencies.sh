#!/bin/bash

#==============
#Check is Root?
#==============
if (( $EUID != 0 )); then
    echo "This script must be run as root"
    exit
fi
echo $EUID


#====================
#Install dependencies
#====================

#Update.
echo ""
echo "======"
echo "Update"
echo "======"
yum -y update


#Package lists.
rpm_check_list=( "yum-utils" "make" "device-mapper-persistent-data" "lvm2" "nfs-utils")

install_options="-y"
_rpm_is_install_packages(){
	echo "Pacakage install check....."
	for package in ${rpm_check_list[@]};
	do
		commands=`rpm -qa | grep "${package}" >& /dev/null; echo $?`
		if [ ${commands} -eq 1 ];
		then
			install_command="yum install ${install_options} ${package}"
			echo ""
			echo "========================================"
                        echo "[Not Installed]  (${package} packages.)"
                        echo "Installing ${package}...."
			echo "========================================"
                        ${install_command} 2>&1 > /dev/null
		else
			echo ""
			echo "========================================"
			echo "[Already Installed] ${package}"
			echo "========================================"
			fi
	done
	echo ""

}

#install check.
_rpm_is_install_packages

#hostname change.
host_name="dev-master"
hostname_cmd=`hostname`
if [ ${hostname_cmd} == ${host_name} ]; then
	echo ""
	echo "========================================"
	echo "host name is already ${host_name}."
	echo "========================================"
else
	change_cmd=`hostnamectl set-hostname ${host_name}`
	echo ""
	echo "========================================"
	${hostname_cmd}
	echo "Change hostname to ${host_name}"
	echo "========================================"
	fi

#===============
#Install Docker.
#===============

#Add docker repository.
echo ""
echo "========================="
echo "Add Docker Repository...."
echo "========================="
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

#Install Docker

echo ""
echo "==================="
echo "Install Docker...."
echo "==================="
yum install ${install_options} docker-ce
#yum install containerd.io

#Checking
docker version

#Run Docker
echo ""
echo "=============="
echo "Run Docker...."
echo "=============="

systemctl enable docker && systemctl start docker
docker_check_cmd=`systemctl status docker | grep "Active:"`
check_str="(running)"
if [[ "${docker_check_cmd}" =~ "${check_str}" ]]; then
	echo ""
	echo "========================"
	echo "Successfully Run docker."
	echo "========================"
else
	echo ""
	echo "================================"
	echo "Docker run failed. check errors."
	echo "================================"
	journalctl -xeu docker
	exit 100
	fi

#Add Docker group

users=`who | awk '{print $1}'`
#Or
#users=`whoami`
echo""
echo "================================"
echo "Add User [${users}] into Docker group."
echo "================================"
usermod -aG docker ${users}

#Check
id ${users}


#=================
#Install Kuernetes
#=================

echo ""
echo "================="
echo "Disable firewalld"
echo "================="

#firewall disable, swap off.
systemctl stop firewalld && systemctl disable firewalld
systemctl status firewalld
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
swapoff -a

#Check.
getenforce

#Set Iptables.
echo -e "net.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1" | tee -a /etc/sysctl.d/k8s.conf
sudo sed -i "s/^\/dev\/mapper\/centos-swap/#\/dev\/mapper\/centos-swap/" /etc/fstab
#Apply.
sysctl --system

echo ""
echo "==============================="
echo "Add Kubernetes repository......"
echo "==============================="

cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF


echo ""
echo "======================================="
echo "Successfully finished. Reboot Please!"
echo "After reboot, run next shell script!"
echo "======================================="
