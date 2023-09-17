#!/bin/bash

if [ -z $1 ]
  then 
    echo "Configured nodes:"
    ls ~/scripts/spacemesh/config | grep node | grep -v sample | sed 's/node//g'
    echo "------------------------"
    read -p "Node?  " id
    echo "------------------------"
  else 
    id=$1
fi
source ~/scripts/spacemesh/config/node$id

pid=$(ps aux | grep spacemesh | grep "$port1" | awk '{print $2}')
kill $pid
sleep 5s
echo "Starting node $id..."
./go-spacemesh --listen /ip4/0.0.0.0/tcp/$port1 --config $config -d $smdata --filelock $lock > ~/logs/spacemesh$id.log 2>&1 &
ps aux | grep spacemesh | grep "$port1"
