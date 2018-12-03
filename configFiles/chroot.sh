#!/bin/bash

mount -t proc proc proc/
apt-get install ganglia-monitor
apt-get update
apt-get upgrade -y

exit
