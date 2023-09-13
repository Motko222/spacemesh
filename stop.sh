#!/bin/bash

read -p "node? " id
source ~/config/spacemesh.sh $id
pid=$(ps aux | grep spacemesh | grep "$port1" | awk '{print $2}')
kill $pid
