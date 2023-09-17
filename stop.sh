#!/bin/bash

source ~/scripts/spacemesh/config/env
if [ -z $1 ]
  then 
    echo "Running nodes:"
    ps aux | grep go-spacemesh | grep -v grep | awk 'match($0, /spacemesh[0-9]|spacemesh[0-9][0-9]/) {print substr($0, RSTART, RLENGTH)}' | sed 's/spacemesh//g'
    echo "------------------------"
    read -p "Node?  " id
    echo "------------------------"
  else 
    id=$1
fi
source ~/scripts/spacemesh/config/node$id

pid=$(ps aux | grep spacemesh | grep "$port1" | awk '{print $2}')
kill $pid
