#!/bin/bash

# rebuild your image after adding or updating packages

# update debian7 vnfs (magic land)
chroot /srv/chroots/debian7 ./chroot.sh

# build image
wwvnfs --chroot /srv/chroots/debian7  --hybridpath=/vnfs

# update the files and everything else!!!!!
wwsh file sync
wwsh dhcp update
wwsh pxe update

# reboot
echo 'success'

echo -n 'Would you like to reboot? yes/no : '
read ANS

until [ "$ANS" == "yes" ] || [ "$ANS" == "no" ]
    do
        echo -n 'Would you like to reboot? yes/no : '  
        read ANS
    done

if [ "$ANS" == "yes" ]; 
    then
        # reboot
        echo 'System will now reboot to finish install'
        sleep 5s; shutdown -r now
    fi
    
echo 'bye'

exit