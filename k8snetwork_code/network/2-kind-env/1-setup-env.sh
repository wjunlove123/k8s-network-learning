#!/bin/bash
date
set -v

# install kind tool
https://kind.sigs.k8s.io/docs/user/quick-start/#installing-from-release-binaries

curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.18.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind


# 1.prep noCNI env
cat <<EOF | kind create cluster --name=flannel-udp --image=kindest/node:v1.23.4 --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  disableDefaultCNI: true
  podSubnet: "10.244.0.0/16"
nodes:
- role: control-plane
- role: worker
- role: worker

containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."192.168.2.100:5000"]
    endpoint = ["http://192.168.2.100:5000"]
EOF

# 2.remove taints
controller_node=`kubectl get nodes --no-headers  -o custom-columns=NAME:.metadata.name| grep control-plane`
kubectl taint nodes $controller_node node-role.kubernetes.io/master:NoSchedule-
kubectl get nodes -o wide

# 3.install CNI
kubectl apply -f ./flannel.yaml

# 4. install necessary tools
for i in $(docker ps  -a --format "table {{.Names}}" | grep flannel-udp)
do 
    echo $i
    docker cp ./bridge $i:/opt/cni/bin/
    docker cp /usr/bin/calicoctl $i:/usr/bin/calicoctl
    docker cp /usr/bin/ping $i:/usr/bin/ping
    docker exec -it $i bash -c "sed -i -e 's/jp.archive.ubuntu.com\|archive.ubuntu.com\|security.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list"
    docker exec -it $i bash -c "apt-get -y update >/dev/null && apt-get -y install net-tools tcpdump lrzsz >/dev/null 2>&1"
done
