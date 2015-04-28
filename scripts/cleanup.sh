#!/bin/sh

# Remove open-vm-tools and its dependencies
for p in open-vm-tools xml-security-c xerces-c libmspack libdnet; do
  tdnf erase -y $p
done

# Remove unnecessary packages
for p in nano gzip cpio libxml2 gdbm; do
  tdnf erase -y $p
done

# Remove packages to build a package from source
for p in tar gcc gawk make glibc-devel linux-api-headers; do
  tdnf erase -y $p
done

tdnf clean all

rm -rf /var/cache/tdnf
rm -f /var/lib/rpm/__db.*
rpm --rebuilddb

rm -rf /run/log/journal/*

> /var/log/lastlog
> /var/log/wtmp
> /var/log/btmp
rm /var/log/mk-install-package.sh*

dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

sync; sync; sync
