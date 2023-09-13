#!/bin/bash

read -p "node? " id
source ~/config/spacemesh.sh $id

cd $smbase

echo "------------------------"
echo "  1  NodeService.Status"
echo "  2  SmesherService.PostSetupStatus"
echo "  3  ActivationService.Highest"
echo "  4  SmesherService.IsSmeshing"
echo "  5  AdminService.EventsStream"
echo "  6  MeshService.MalfeasanceStream"
echo "------------------------"
read -p "Action? " action

case $action in
1) ./grpcurl --plaintext -d "{}" localhost:$port2 spacemesh.v1.NodeService.Status ;;
2) ./grpcurl --plaintext -d "{}" localhost:$port3 spacemesh.v1.SmesherService.PostSetupStatus ;;
3) ./grpcurl -plaintext 127.0.0.1:$port2 spacemesh.v1.ActivationService.Highest ;;
4) ./grpcurl -d '{}' -plaintext localhost:$port3 spacemesh.v1.SmesherService.IsSmeshing ;;
5) ./grpcurl -plaintext -d "{}" localhost:$port3 spacemesh.v1.AdminService.EventsStream ;;
6) ./grpcurl -plaintext 127.0.0.1:$port2 spacemesh.v1.MeshService.MalfeasanceStream ;;
esac
