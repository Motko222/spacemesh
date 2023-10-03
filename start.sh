#!/bin/bash

source ~/scripts/spacemesh/config/env
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
cd $smbase
pid=$(ps aux | grep spacemesh | grep "$port1" | awk '{print $2}')

if [ -z $pid ]
  then 
    echo "Node $id is not running..."
  else 
    echo "Killing process $pid..."
    kill $pid
    sleep 5s
fi

echo "Starting node $id ($port1 $config $smdata $lock)..."
./go-spacemesh --listen /ip4/0.0.0.0/tcp/$port1 --config $config -d $smdata --filelock $lock > ~/logs/spacemesh$id.log 2>&1 &
ps aux | grep spacemesh | grep "$port1"
