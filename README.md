# Dev Platform project
------------
## Project Description
> 내부 컨테이너로 동작하는 VSCode 컨테이너를 제공하여, 개발 플랫폼을 만드는 프로젝트 입니다.
> 내부 컨테이너에서, 알고리즘, 인공지능 Code Template 등을 제공하고, 커스터마이징 기능을 제공합니다.

### Systems
> 이 프로젝트는 shell script 들을 run하여, 플랫폼이 구동될 System을 손쉽게 구축해 주는 프로젝트 입니다.

```
#sudo need.
sudo ./0.dependencies.sh
sudo ./1.install_kubernetes.sh

#User account.
./2.setting_kubelet.sh
./3.nfs-server.sh

#Check
kubectl get pod -A
```

## Support Server OS
+ CentOS 7

## Install lists
+ docker
+ kubernetes
+ nfs-utils
