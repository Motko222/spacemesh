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
  read -p "URL? " url
  echo "Downloading..."
  wget $url
  unzip -j Linux.zip
  echo "Setting permissions..."
  chmod 777 go-spacemesh profiler
  echo "Deleting zip..."
  rm Linux.zip
  if [ -f ~/scripts/spacemesh/config/env] 
    then
      echo "Config file found."
    else
      echo "Config file not found, creating one."
      cp ~/scripts/spacemesh/config/env.sample ~/scripts/spacemesh/config/env
  fi
  echo "Done."
 ;;
 esac
