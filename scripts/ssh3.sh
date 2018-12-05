#!/bin/bash

# ask for non-root user
read -p "Enter the non-root username: "  nonroot
# masternode
masternode=$(hostname)

# change to non-root user
su - $nonroot << EOF
cd
echo | ssh-keygen -Pt rsa ''
exit
EOF

# copy key 
su - $nonroot << EOF
cd ~/.ssh
cp id_rsa.pub authorized_keys
exit
EOF

su - $nonroot << EOF
ssh -y n0001 'ssh -y $masternode 'exit'; exit'
exit
EOF

# try to ssh via ssh
su - $nonroot << EOF
ssh n0001 'ssh $masternode 'exit'; exit'
exit
EOF

pdsh -R ssh -w $masternode,n0001 hostname
pdsh -R ssh -w $masternode,n0001 uname -a
exit
