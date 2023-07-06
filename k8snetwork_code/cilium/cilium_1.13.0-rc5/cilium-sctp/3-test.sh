#/bin/bash

set -v
#expose the svc
kubectl expose deployment sctp-deployment --port=9999 --type=NodePort >/dev/null 2>&1

#get svc port
PORT=$(kubectl get svc/sctp-deployment -o jsonpath='{.spec.ports[0].nodePort}')
echo $PORT

NODE_IP=$(kubectl get nodes -o jsonpath='{.items[?(@.metadata.name=="cilium-kubeproxy-sctp-worker")].status.addresses[?(@.type=="InternalIP")].address}')
echo $NODE_IP

apt install -y ncat >/dev/null 2>&1

ncat --sctp $NODE_IP $PORT

