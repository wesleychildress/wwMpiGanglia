#!/bin/bash
#this piece of shit doesn't work as of yet 

# current directory for reference
DIR=$( pwd )
# masternode
masternode=$(hostname)

# ssh to n0001
cd $DIR/scripts
./ssh1.sh

# save host keys ssh
./ssh2.sh

# pdsh ssh
./ssh3.sh
cd $DIR

# reboot nodes
pdsh -R ssh -w n0001

exit
