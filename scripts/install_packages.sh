#!/bin/sh
set -e

mount /dev/cdrom /media/cdrom
tdnf install -y sudo

# Install packages to build a package from source
for p in tar gcc gawk make glibc-devel linux-api-headers; do
  tdnf install -y $p
done

umount /media/cdrom

# http://www.linuxfromscratch.org/blfs/view/svn/basicnet/libtirpc.html
# http://sourceforge.net/projects/libtirpc/files/libtirpc/
cd /tmp
curl -OL http://downloads.sourceforge.net/libtirpc/libtirpc-0.2.5.tar.bz2
bzip2 -d libtirpc-0.2.5.tar.bz2
tar xf libtirpc-0.2.5.tar
cd libtirpc-0.2.5

./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-static  \
            --disable-gssapi  &&
make
make install
mv -v /usr/lib/libtirpc.so.* /lib
cd /usr/lib
ln -sfv ../../lib/libtirpc.so.1.0.10 /usr/lib/libtirpc.so

rm -f /tmp/libtirpc-0.2.5.tar
rm -rf /tmp/libtirpc-0.2.5

# http://www.linuxfromscratch.org/blfs/view/svn/basicnet/rpcbind.html
# http://sourceforge.net/projects/rpcbind/files/rpcbind/
cd /tmp
curl -OL http://downloads.sourceforge.net/rpcbind/rpcbind-0.2.3.tar.bz2
bzip2 -d rpcbind-0.2.3.tar.bz2
tar xf rpcbind-0.2.3.tar
cd rpcbind-0.2.3
sed -i "/servname/s:rpcbind:sunrpc:" src/rpcbind.c &&
sed -i "/error = getaddrinfo/s:rpcbind:sunrpc:" src/rpcinfo.c

./configure --prefix=/usr       \
            --bindir=/sbin      \
            --with-rpcuser=root \
            --without-systemdsystemunitdir &&
make
make install

rm -f /tmp/rpcbind-0.2.2.tar
rm -rf /tmp/rpcbind-0.2.2

# http://www.linuxfromscratch.org/blfs/view/svn/basicnet/nfs-utils.html
# http://sourceforge.net/projects/nfs/files/nfs-utils/
cd /tmp
curl -OL http://downloads.sourceforge.net/nfs/nfs-utils-1.3.2.tar.bz2
bzip2 -d nfs-utils-1.3.2.tar.bz2
tar xf nfs-utils-1.3.2.tar
cd nfs-utils-1.3.2
sed -i "/daemon_init/s:\!::" utils/statd/statd.c

./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --without-tcp-wrappers \
            --disable-nfsv4        \
            --disable-gss &&
make
make install

rm -f /tmp/nfs-utils-1.3.2.tar
rm -rf /tmp/nfs-utils-1.3.2

# https://github.com/vmware/photon/issues/24
cd /tmp
curl -OL https://github.com/higebu/photon/releases/download/systemd-216-2/systemd-216-2.x86_64.rpm
rpm -Uvh systemd-216-2.x86_64.rpm
rm -f systemd-216-2.x86_64.rpm

# Install the latest version of Docker
cd /tmp
curl -OL https://get.docker.com/builds/Linux/x86_64/docker-1.6.0.tgz
tar xzf docker-1.6.0.tgz -C /usr/bin --strip-components=3
rm -f docker-1.6.0.tgz
