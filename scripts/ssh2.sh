#!/bin/bash

# ask for non-root user
read -p "Enter the non-root username: "  non-root
# masternode
masternode=$(hostname)

# change to non-root user
su $non-root

cd
echo -ne '\n' | ssh-keygen -t rsa
# *****(enter no passphrase)
cd ~/.ssh
cp id_rsa.pub authorized_keys
cd
ssh -y n0001 'ssh -y $masternode; exit'
exit
# try to ssh via ssh
ssh -y n0001 'ssh -y $masternode; exit'
exit
pdsh -R ssh -w (masternodename),n0001 hostname
pdsh -R ssh -w (masternodename),n0001 uname -a
exit
exit
