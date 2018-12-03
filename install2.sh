#!/bin/bash

# current directory for reference
DIR=$( pwd )
masternode=$(hostname)
wwsh node new n0001 --hwaddr=$ --ipaddr=10.253.1.1
# ssh to n0001
.$DIR/scripts/ssh1

# save host keys ssh
.$DIR/scripts/ssh2

# pdsh as rooot
.$DIR/scripts/ssh3
