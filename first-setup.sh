#!/bin/bash
# sudo apt update 
# sudo apt install git -y
# git clone https://github.com/KasarLabs/kasarOs && cd kasarOs && git checkout roc-dev

git config pull.ff only
sudo su -
cd /home/starknode/kasarOs/
git config --global --add safe.directory /home/starknode/kasarOs
mv rc.local /etc/rc.local