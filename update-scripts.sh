#!/bin/bash

cd ~/scripts/spacemesh
git stash push --include-untracked
git pull
chmod +x *.sh
