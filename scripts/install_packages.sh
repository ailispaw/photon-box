#!/bin/sh
set -e

mount /dev/cdrom /media/cdrom
tdnf install -y sudo

# Remove open-vm-tools and its dependencies
for p in open-vm-tools xml-security-c xerces-c libmspack libdnet; do
  tdnf erase -y $p
done

# Install packages to build a package from source
for p in tar gcc gawk make glibc-devel linux-api-headers; do
  tdnf install -y $p
done

tdnf clean all
umount /media/cdrom

# http://www.linuxfromscratch.org/blfs/view/svn/basicnet/libtirpc.html
cd /tmp
curl -OL http://downloads.sourceforge.net/project/libtirpc/libtirpc/0.2.5/libtirpc-0.2.5.tar.bz2
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
cd /tmp
curl -OL http://downloads.sourceforge.net/rpcbind/rpcbind-0.2.2.tar.bz2
bzip2 -d rpcbind-0.2.2.tar.bz2
tar xf rpcbind-0.2.2.tar
cd rpcbind-0.2.2
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
