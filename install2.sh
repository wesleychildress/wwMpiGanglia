#!/bin/bash

# current directory for reference
DIR=$( pwd )
# masternode
masternode=$(hostname)

# ask for non-root user
read -p "Enter the MAC address of n0001: "  MAC
wwsh node new n0001 --hwaddr=$MAC --ipaddr=10.253.1.1

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
