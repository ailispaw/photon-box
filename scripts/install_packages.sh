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
VERSION=0.3.0
cd /tmp
curl -OL http://downloads.sourceforge.net/libtirpc/libtirpc-${VERSION}.tar.bz2
bzip2 -d libtirpc-${VERSION}.tar.bz2
tar xf libtirpc-${VERSION}.tar
cd libtirpc-${VERSION}

sed -e '/rpcsec_gss.h/         i #ifdef HAVE_RPCSEC_GSS' \
    -e '/svc_rpc_gss_parms_t;/ a #endif' \
    -e '/svc_rpc_gss_parms_t / i #ifdef HAVE_RPCSEC_GSS' \
    -e '/rpc_gss_rawcred_t /   a #endif' \
    -i tirpc/rpc/svc_auth.h

./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-static  \
            --disable-gssapi  &&
make
make install
mv -v /usr/lib/libtirpc.so.* /lib
cd /usr/lib
ln -sfv ../../lib/libtirpc.so.1.0.10 /usr/lib/libtirpc.so

rm -f /tmp/libtirpc-${VERSION}.tar
rm -rf /tmp/libtirpc-${VERSION}

# http://www.linuxfromscratch.org/blfs/view/svn/basicnet/rpcbind.html
# http://sourceforge.net/projects/rpcbind/files/rpcbind/
VERSION=0.2.3
cd /tmp
curl -OL http://downloads.sourceforge.net/rpcbind/rpcbind-${VERSION}.tar.bz2
bzip2 -d rpcbind-${VERSION}.tar.bz2
tar xf rpcbind-${VERSION}.tar
cd rpcbind-${VERSION}
sed -i "/servname/s:rpcbind:sunrpc:" src/rpcbind.c

./configure --prefix=/usr       \
            --bindir=/sbin      \
            --with-rpcuser=root \
            --without-systemdsystemunitdir &&
make
make install

rm -f /tmp/rpcbind-${VERSION}.tar
rm -rf /tmp/rpcbind-${VERSION}

# http://www.linuxfromscratch.org/blfs/view/svn/basicnet/nfs-utils.html
# http://sourceforge.net/projects/nfs/files/nfs-utils/
VERSION=1.3.2
cd /tmp
curl -OL http://downloads.sourceforge.net/nfs/nfs-utils-${VERSION}.tar.bz2
bzip2 -d nfs-utils-${VERSION}.tar.bz2
tar xf nfs-utils-${VERSION}.tar
cd nfs-utils-${VERSION}
sed -i "/daemon_init/s:\!::" utils/statd/statd.c

./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --without-tcp-wrappers \
            --disable-nfsv4        \
            --disable-gss &&
make
make install

rm -f /tmp/nfs-utils-${VERSION}.tar
rm -rf /tmp/nfs-utils-${VERSION}

# https://github.com/vmware/photon/issues/24
VERSION=216-2
cd /tmp
curl -OL https://github.com/higebu/photon/releases/download/systemd-${VERSION}/systemd-${VERSION}.x86_64.rpm
rpm -Uvh systemd-${VERSION}.x86_64.rpm
rm -f systemd-${VERSION}.x86_64.rpm

# Install the latest version of Docker
DOCKER_VERSION=1.7.0
cd /tmp
curl -OL https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz
tar xzf docker-${DOCKER_VERSION}.tgz -C /usr/bin --strip-components=3
rm -f docker-${DOCKER_VERSION}.tgz
