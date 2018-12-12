#!/bin/bash

mount -t proc proc proc/

cd slurm-18 
./configure
make
make install

exit