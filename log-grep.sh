#!/bin/bash

  read -p "node? " id
  read -p "search? " grp
  cat ~/logs/spacemesh$id.log | grep "$grp"
