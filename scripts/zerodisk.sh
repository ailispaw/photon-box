#!/bin/sh

rm -rf /var/cache/tdnf
rm -f /var/lib/rpm/__db.*
rpm --rebuilddb

rm -rf /run/log/journal/*

dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

sync; sync; sync
