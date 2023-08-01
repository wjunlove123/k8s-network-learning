#!/bin/bash
date
set -v
# 4. install necessary tools
for i in $(docker ps  -a --format "table {{.Names}}" | grep control-plane)
do 
    echo $i
    docker exec -it $i bash -c "sed -i -e 's/jp.archive.ubuntu.com\|archive.ubuntu.com\|security.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list"
    docker exec -it $i bash -c "apt-get -y update >/dev/null && apt-get -y install net-tools tcpdump lrzsz >/dev/null"
done