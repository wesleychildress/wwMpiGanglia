#!/bin/bash
apt-get update
apt-get upgrade
apt-get install -f

# List of necessary packages
LIST_OF_APPS="ssh ntp qt-sdk pkg-config ncurses-dev nfs-server libselinux1-dev pdsh tftp gfortran
libxml2-dev libboost-dev tk-dev apache2 libapache2-mod-perl2 tftpd-hpa debootstrap tcpdump
isc-dhcp-server curl libterm-readline-gnu-perl apache2 php5 php5-mysql libapache2-mod-php5
ganglia-monitor rrdtool gmetad ganglia-webfrontend"
# current directory for reference
DIR=$( pwd )

# set up permanent networking connections
mv -f /etc/network/interfaces /etc/network/interfaces.og
cp -f $DIR/configFiles/interfaces /etc/network/interfaces
/etc/init.d/networking restart

#install essential build tools:
apt-get install -y build-essential

# install mariadb (new, updated mysql):
apt-get install -y mysql-server mysql-client

# install other important packages:
apt-get install -y $LIST_OF_APPS

# set selinux to permisive
mv -f /etc/selinux/config /etc/selinux/config.og
cp -f $( pwd )/configFiles/config /etc/selinux/config
setenforce 0

# start ganglia services
cp /etc/ganglia-webfrontend/apache.conf /etc/apache2/sites-enabled/ganglia.conf
#/etc/ganglia/gmetad.conf
#/etc/ganglia/gmond.conf
/etc/init.d/ganglia-monitor start
/etc/init.d/gmetad start
/etc/init.d/apache2 restart

# Build and install MPICH
cd $DIR/mpich
tar zxvf mpich-3.2.1.tar.gz
cd mpich-3.2.1
./configure --enable-fc --enable-f77 --enable-romio --enable-mpe --with-pm=hydra
# make & install
make
make install
cd $DIR

# install warewulf
cd $DIR/src
chmod +x install-wwdebsystem
./install-wwdebsystem 3.6
cd $DIR

# make copy of original config files then move these into place
mv -f /etc/exports /etc/exports.og
cp -f $DIR/configFiles/exports /etc/exports

mv -f /usr/local/libexec/warewulf/wwmkchroot/include-deb /usr/local/libexec/warewulf/wwmkchroot/include-deb.og
cp -f $DIR/configFiles/include-deb /usr/local/libexec/warewulf/wwmkchroot/include-deb

mv -f /usr/local/etc/warewulf/vnfs.conf /usr/local/etc/warewulf/vnfs.conf.og
cp -f $DIR/configFiles/vnfs.conf /usr/local/etc/warewulf/vnfs.conf

cp -f $DIR/configFiles/debian7.tmpl /usr/local/libexec/warewulf/wwmkchroot/debian7.tmpl

# cp config files start ganglia services
cp /etc/ganglia-webfrontend/apache.conf /etc/apache2/sites-enabled/ganglia.conf
mv -f /etc/ganglia/gmetad.conf /etc/ganglia/gmetad.conf.og
cp -f $DIR/configFiles/gmetad.conf /etc/ganglia/gmetad.conf
mv -f /etc/ganglia/gmond.conf /etc/ganglia/gmond.conf.og
cp -f $DIR/configFiles/gmond.conf /etc/ganglia/gmond.conf

# start ganglia services
/etc/init.d/ganglia-monitor start
/etc/init.d/gmetad start
/etc/init.d/apache2 restart

# Create directories necessary for successful chrooting:
mkdir /srv/chroots
mkdir /srv/chroots/debian7
mkdir /srv/chroots/debian7/vnfs
mkdir /srv/chroots/debian7/srv
mkdir /srv/chroots/debian7/srv/chroots

# create warewulf chroot:
wwmkchroot debian7 /srv/chroots/debian7

# make copy of original config files then move these into place
mv -f /etc/idmapd.conf /etc/idmapd.conf.og
mv -f /srv/chroots/debian7/etc/idmapd.conf /srv/chroots/debian7/etc/idmapd.conf.og
cp -f $DIR/configFiles/idmapd.conf /etc/idmapd.conf
cp -f $DIR/configFiles/idmapd.conf /srv/chroots/debian7/etc/idmapd.conf

mv -f /etc/default/nfs-common /etc/default/nfs-common.og
cp -f $DIR/configFiles/nfs-common /etc/default/nfs-common

mv -f /usr/local/etc/warewulf/defaults/node.conf /usr/local/etc/warewulf/defaults/node.conf.og
cp -f $DIR/configFiles/node.conf /usr/local/etc/warewulf/defaults/node.conf

mv -f /usr/local/etc/warewulf/defaults/provision.conf /usr/local/etc/warewulf/defaults/provision.conf.og
cp -f $DIR/configFiles/provision.conf /usr/local/etc/warewulf/defaults/provision.conf

mv -f /usr/local/etc/warewulf/bootstrap.conf /usr/local/etc/warewulf/bootstrap.conf.og
cp -f $DIR/configFiles/bootstrap.conf /usr/local/etc/warewulf/bootstrap.conf

mv -f /srv/chroots/debian7/etc/fstab /srv/chroots/debian7/etc/fstab.og
cp -f $DIR/configFiles/fstab /srv/chroots/debian7/etc/fstab

mv -f /srv/chroots/debian7/etc/rc.local /srv/chroots/debian7/etc/rc.local.og
cp -f $DIR/configFiles/rc.local /srv/chroots/debian7/etc/rc.local

# ask for n0001 MAC
read -p "Enter the MAC address of n0001: "  MAC
wwsh node new n0001 --hwaddr=$MAC --ipaddr=10.253.1.1

# restart nfs on master node
/etc/init.d/nfs-kernel-server restart
/etc/init.d/nfs-common restart

# Verify the appropriate nfs filesystems are being exported by the master node:
showmount -e 10.253.1.254

# Restart the tftp server:
/etc/init.d/tftpd-hpa restart

# Build chroot environment and install:
wwvnfs --chroot /srv/chroots/debian7  --hybridpath=/vnfs
wwsh dhcp update

# put ./chroot.sh in place
cp $DIR/configFiles/chroot.sh /srv/chroots/debian7/chroot.sh
#cp $DIR/configFiles/gangliaIn.sh /srv/chroots/debian7/gangliaIn.sh

# update sources
mv -f /srv/chroots/debian7/etc/apt/sources.list /srv/chroots/debian7/etc/apt/sources.list.og
cp -f $DIR/configFiles/sources.list /srv/chroots/debian7/etc/apt/sources.list

# We want the clocks to be the same on all nodes (synchronized)
mv -f /srv/chroots/debian7/etc/ntp.conf /srv/chroots/debian7/etc/ntp.conf.og
cp -f $DIR/configFiles/ntp.conf /srv/chroots/debian7/etc/ntp.conf

# install ganglia monitor in magic land
#chroot /srv/chroots/debian7 ./gangliaIn.sh

# move ganglia config into place
mv -f /srv/chroots/debian7/etc/ganglia/gmond.conf /srv/chroots/debian7/etc/ganglia/gmond.conf.og
cp -f $DIR/configFiles/clientGmond.conf /srv/chroots/debian7/etc/ganglia/gmond.conf

# update debian7 vnfs (magic land)
chroot /srv/chroots/debian7 ./chroot.sh

# build image
wwvnfs --chroot /srv/chroots/debian7  --hybridpath=/vnfs

# update the files and everything else!!!!!
wwsh file sync
wwsh dhcp update
wwsh pxe update
echo 'success'

# reboot
echo 'System will now reboot to finish install'
sleep 5s; shutdown -r now
exit
