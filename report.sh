#!/bin/bash

source ~/scripts/spacemesh/config/env
source ~/.bash_profile

group=node
network=mainnet
chain=mainnet
owner=$OWNER

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
version=$(./grpcurl -plaintext localhost:$port2 spacemesh.v1.NodeService.Version | jq .versionString.value | sed 's/"//g')
smesherId=0x$(./grpcurl -plaintext localhost:$port3 spacemesh.v1.SmesherService.SmesherID | jq .publicKey | sed 's/"//g' | base64 -d | od -t x1 -An | tr -dc '[:xdigit:]')
address=$(./grpcurl -plaintext localhost:$port3 spacemesh.v1.SmesherService.Coinbase | jq .accountId.address | sed 's/"//g')

#network status
json=$(./grpcurl --plaintext -d "{}" localhost:$port2 spacemesh.v1.NodeService.Status)
peers=$(echo $json | jq .status.connectedPeers | sed 's/"//g')
syncedlayer=$(echo $json | jq .status.syncedLayer.number | sed 's/"//g')
toplayer=$(echo $json | jq .status.topLayer.number | sed 's/"//g')
verifiedlayer=$(echo $json | jq .status.verifiedLayer.number | sed 's/"//g')
synced=$(echo $json | jq .status.isSynced | sed 's/"//g')

#smesher status
smeshing=$(./grpcurl -d '{}' -plaintext localhost:$port3 spacemesh.v1.SmesherService.IsSmeshing | jq .isSmeshing)

#post status
json=$(./grpcurl --plaintext -d "{}" localhost:$port3 spacemesh.v1.SmesherService.PostSetupStatus)
postdir=$(echo $json | jq .status.opts.dataDir | sed 's/"//g')
units=$(echo $json | jq .status.opts.numUnits | sed 's/"//g')

foldersize=$(du -hs $smbase | awk '{print $1}')
postsize=$(du -hs $postdir | awk '{print $1}')
logsize=$(du -hs $HOME/logs/spacemesh$id.log | awk '{print $1}')
poetWait=$(cat ~/logs/spacemesh$id.log | grep "waiting until poet round end" | tail -1 | awk '{print substr($0, 6, 11)}' | sed 's/T/ /')

case $synced$smeshing in
 truetrue)   status="ok";       message="size $postsize | wait $poetWait" ;;
 truenull)   status="warning";  message="node synced, but not smeshing" ;;
 nulltrue)   status="warning";  message="sync $syncedlayer/$toplayer" ;;
 nullnull)   status="warning";  message="sync $syncedlayer/$toplayer, not smeshing" ;;
 *)          status="error";    message="fetch error" ;;
esac

if [ -z $pid ]; then status="error";message="process not running"; fi

id=spacemesh-$id

cat << EOF
{
  "id":"$id",
  "machine":"$MACHINE",
  "version":"$version",
  "chain":"$chain",
  "type":"node",
  "pid":"$pid",
  "status":"$status",
  "message":"$message",
  "foldersize":"$foldersize",
  "logsize":"$logsize",
  "postdir":"$postdir",
  "postsize":"$postsize",
  "synced":"$synced",
  "smeshing":"$smeshing",
  "updated":"$(date --utc +%FT%TZ)"
}
EOF

# send data to influxdb
if [ ! -z $INFLUX_HOST ]
then
 curl --request POST \
 "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=$INFLUX_BUCKET&precision=ns" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary "
    report,id=$id,machine=$MACHINE,grp=$group,owner=$owner status=\"$status\",message=\"$message\",version=\"$version\",url=\"$url\",chain=\"$chain\",network=\"$network\" $(date +%s%N) 
    "
fi
