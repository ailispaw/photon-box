#!/bin/sh
set -e

KERNEL_VERSION=3.19.2
VBOX_VERSION=4.3.28

cd /usr/src
curl -OL https://www.kernel.org/pub/linux/kernel/v3.x/linux-${KERNEL_VERSION}.tar.xz
tar xPJf linux-${KERNEL_VERSION}.tar.xz

cd linux-${KERNEL_VERSION}
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
rm -rf amd64/src/vboxguest-${VBOX_VERSION}/vboxvideo
KERN_DIR=/usr/src/linux-${KERNEL_VERSION} KERN_INCL=/usr/src/include make -C amd64/src/vboxguest-${VBOX_VERSION}

cp amd64/src/vboxguest-${VBOX_VERSION}/*.ko /lib/modules/${KERNEL_VERSION}/
cp amd64/lib/VBoxGuestAdditions/mount.vboxsf /sbin
depmod -a

umount /media/GuestAdditionsISO

rm -f /usr/src/linux-${KERNEL_VERSION}.tar.xz
rm -rf /usr/src/linux-${KERNEL_VERSION}
rm -rf /usr/src/include
rm -rf /vboxguest
rm -f /root/VBoxGuestAdditions.iso
rm -rf /media/GuestAdditionsISO
