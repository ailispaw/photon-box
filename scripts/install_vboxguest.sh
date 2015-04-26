#!/bin/sh
set -e

cd /usr/src
curl -OL https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.19.2.tar.xz
tar xPJf linux-3.19.2.tar.xz

cd linux-3.19.2
curl -L https://raw.githubusercontent.com/vmware/photon/master/support/package-builder/config -o .config
make oldconfig
make prepare && make scripts
make headers_install INSTALL_HDR_PATH=/usr/src

mkdir -p /media/GuestAdditionsISO
mount -o loop /root/VBoxGuestAdditions.iso /media/GuestAdditionsISO

mkdir -p /vboxguest
cd /media/GuestAdditionsISO
./VBoxLinuxAdditions.run --noexec --target /vboxguest

cd /vboxguest
mkdir -p amd64 && tar -C amd64 -xjf VBoxGuestAdditions-amd64.tar.bz2
rm -rf amd64/src/vboxguest-4.3.26/vboxvideo
KERN_DIR=/usr/src/linux-3.19.2 KERN_INCL=/usr/src/include make -C amd64/src/vboxguest-4.3.26

cp amd64/src/vboxguest-4.3.26/*.ko /lib/modules/3.19.2/
cp amd64/lib/VBoxGuestAdditions/mount.vboxsf /sbin
depmod -a

rm -f /usr/src/linux-3.19.2.tar.xz
rm -rf /usr/src/linux-3.19.2
rm -rf /usr/src/include
rm -rf /vboxguest
rm -f /root/VBoxGuestAdditions.iso
