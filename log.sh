#!/bin/bash

read -p "node? " id
tail -f ~/logs/spacemesh$id.log
