#!/bin/sh

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
