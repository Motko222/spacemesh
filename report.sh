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

cd $smbase  
pid=$(ps aux | grep spacemesh | grep $port1 | awk '{print $2}')
network="mainnet"
version=$(./grpcurl -plaintext localhost:$port2 spacemesh.v1.NodeService.Version | jq .versionString.value | sed 's/"//g')
smesherId=0x$(./grpcurl -plaintext localhost:$port3 spacemesh.v1.SmesherService.SmesherID | jq .publicKey | sed 's/"//g' | base64 -d | od -t x1 -An | tr -dc '[:xdigit:]')
address=$(./grpcurl -plaintext localhost:$port3 spacemesh.v1.SmesherService.Coinbase | jq .accountId.address | sed 's/"//g')

#network status
json=$(./grpcurl --plaintext -d "{}" localhost:$port2 spacemesh.v1.NodeService.Status)
peers=$(echo $json | jq .status.connectedPeers | sed 's/"//g')
syncedlayer=$(echo $json | jq .status.syncedLayer.number | sed 's/"//g')
toplayer=$(echo $json | jq .status.topLayer.number | sed 's/"//g')
verifiedlayer=$(echo $json | jq .status.verifiedLayer.number | sed 's/"//g')
issynced=$(echo $json | jq .status.isSynced | sed 's/"//g')

#smesher status
issmeshing=$(./grpcurl -d '{}' -plaintext localhost:$port3 spacemesh.v1.SmesherService.IsSmeshing | jq .isSmeshing)

#post status
json=$(./grpcurl --plaintext -d "{}" localhost:$port3 spacemesh.v1.SmesherService.PostSetupStatus)
postdir=$(echo $json | jq .status.opts.dataDir | sed 's/"//g')
units=$(echo $json | jq .status.opts.numUnits | sed 's/"//g')

foldersize=$(du -hs $smbase | awk '{print $1}')
postsize=$(du -hs $postdir | awk '{print $1}')
logsize=$(du -hs $HOME/logs/spacemesh$id.log | awk '{print $1}')
type=$postsize
poetWait=$(cat ~/logs/spacemesh$id.log | grep "waiting until poet round end" | tail -1 | awk '{print substr($0, 6, 11)}' | sed 's/T/ /')

case $issynced$issmeshing in
 truetrue)   status="ok";       note="waiting $poetWait" ;;
 truenull)   status="warning";  note="node synced, but not smeshing" ;;
 nulltrue)   status="warning";  note="sync $syncedlayer/$toplayer" ;;
 nullnull)   status="warning";  note="sync $syncedlayer/$toplayer, not smeshing" ;;
 *)          status="error";    note="fetch error" ;;
esac

if [ -z $pid ]; then status="error";note="process not running"; fi

echo "updated='$(date +'%y-%m-%d %H:%M')'"
echo "version='$version'"
echo "process='$pid'"
echo "status=$status"
echo "note='$note'"
echo "network='$network'"
echo "type=$type"
echo "foldersize=$foldersize"
echo "logsize=$logsize"
echo "postdir=$postdir"
echo "postsize=$postsize"
echo "issynced=$issynced"
echo "issmeshing=$issmeshing"
