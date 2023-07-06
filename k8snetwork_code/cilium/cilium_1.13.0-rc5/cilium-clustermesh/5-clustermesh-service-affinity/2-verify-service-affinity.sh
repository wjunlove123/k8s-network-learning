#!/bin/bash
set -v
# exec &>./verify-log-rec-2-verify-service-affinity.txt
NREQUESTS=10

echo "------------------------------------------------------"
echo Current_Context View:
echo "------------------------------------------------------"
kubectl config get-contexts

for affinity in local remote none; do
  echo "------------------------------------------------------"
  rm -f $affinity.txt
  echo "Sending $NREQUESTS requests to service-affinity=$affinity service"
  echo "------------------------------------------------------"
  for i in $(seq 1 $NREQUESTS); do
  Current_Cluster=`kubectl -n service-affinity exec -it ds/netshoot -- curl -q "http://echoserver-service-$affinity.service-affinity.svc.cluster.local?echo_env_body=NODE"` 
  echo -e Current_Rsp_From_Cluster: ${Current_Cluster}
  done
done
echo "------------------------------------------------------"
