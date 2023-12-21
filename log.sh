#!/bin/bash

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

tail -f ~/logs/spacemesh$id.log
