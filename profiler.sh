#!/bin/bash

source ~/scripts/spacemesh/config/env
cd $smbase

read -p "threads? " threads
read -p "nonces? " nonces
read -p "path? " path
./profiler --data-size 1 --threads=$threads --data-file $path/data.bin --nonces=$nonces
