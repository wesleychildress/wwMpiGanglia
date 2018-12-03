#!/bin/bash

mount -t proc proc proc/
apt-get update
apt-get upgrade -y

exit