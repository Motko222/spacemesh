#!/bin/bash

source ~/scripts/spacemesh/config/env

read -p "Sure?" c
 case $c in
 y)
  if [ -d $smbase ]
    then
      echo "Removing old files..."
      cd $smbase
      rm go-spacemesh libpost.so profiler
    else
      mkdir $smbase
      cd $smbase
  fi
  echo "Get latest release from here: https://github.com/spacemeshos/go-spacemesh/releases"
  read -p "Release? " release
  url="https://storage.googleapis.com/go-spacemesh-release-builds/$release/go-spacemesh-$release-linux-amd64.zip"
  file="go-spacemesh-$release-linux-amd64.zip"
  echo "Downloading... $url"
  wget $url
  unzip -j $file
  echo "Setting permissions..."
  chmod 777 go-spacemesh profiler
  echo "Deleting $file..."
  rm $file
  if [ -f ~/scripts/spacemesh/config/env ] 
    then
      echo "Config file found."
    else
      echo "Config file not found, creating one."
      cp ~/scripts/spacemesh/config/env.sample ~/scripts/spacemesh/config/env
      cp ~/scripts/spacemesh/config/node.sample ~/scripts/spacemesh/config/node1
  fi
  echo "Done."
 ;;
 esac
