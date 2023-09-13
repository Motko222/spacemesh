#!/bin/bash

source ~/config/spacemesh.sh

read -p "Sure?" c
 case $c in
 y)
  echo "removing old files..."
  cd $smbase
  rm go-spacemesh libpost.so profiler
  echo "Get latest release from here: https://github.com/spacemeshos/go-spacemesh/releases"
  read -p "URL? " url
  echo "downloading..."
  wget $url
  unzip -j Linux.zip
  echo "setting permissions..."
  chmod 777 go-spacemesh profiler
  echo "deleting zip..."
  rm Linux.zip
  echo "done."
 ;;
 esac
