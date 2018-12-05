#!/bin/bash

# masternode
masternode=$(hostname)
# as root
ssh -y n0001 'ssh -y $masternode 'exit'; exit'

pdsh -R ssh -w $masternode,n0001 hostname
pdsh -R ssh -w $masternode,n0001 uname -a
exit
