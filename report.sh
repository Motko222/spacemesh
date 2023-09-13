#!/bin/bash

read -p "node? " id
source ~/config/spacemesh.sh $id
cd $smbase  
pid=$(ps aux | grep spacemesh | grep $port1 | awk '{print $2}')
network="mainnet"
version=$(./grpcurl -plaintext localhost:$port2 spacemesh.v1.NodeService.Version | jq .versionString.value | sed 's/"//g')
smesherId=0x$(./grpcurl -plaintext localhost:$port3 spacemesh.v1.SmesherService.SmesherID | jq .publicKey | sed 's/"//g' | base64 -d | od -t x1 -An | tr -dc '[:xdigit:]>
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
poetWait=$(cat ~/logs/spacemesh$id.log | grep "waiting till poet round end" | tail -1 | awk '{print $1}')

status="ok";
if [ "$issynced" = "true" ]; then status="ok" ; else status="warning";note="node not synced"; fi
if [ "$issmeshing" = "true" ]; then status="ok";note="waiting $poetWait"; else status="warning";note="node not smeshing"; fi
if [ -z $pid ]; then status="error";note="process not running"; fi

echo "updated='$(date +'%y-%m-%d %H:%M')'"
echo "version='$version'"
echo "process='$pid'"
echo "status="$status 
echo "note='$note'"
echo "network='$network'"
echo "type="$type
echo "foldersize="$foldersize
echo "logsize="$logsize
echo "postdir="$postdir
echo "postsize="$postsize
