#!/bin/bash

mount -t proc proc proc/

./configure
make
make install

exit