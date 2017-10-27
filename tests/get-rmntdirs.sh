#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../include/common.inc
. ../lib/subc

_debug=false
_debug_level=1
filesdir=../tmp/files

echo '-- No mounted --'
_mntdirs=""
cat $filesdir/mount.log | get-rmntdirs cat

echo '-- 1 mounted --'
_mntdirs="/mnt"
cat $filesdir/mount-1.log | get-rmntdirs cat

echo '-- many mounted(4 of 4) --'
_mntdirs="/mnt /mnt1 /mnt2 /mnt3"
cat $filesdir/mount-2.log | get-rmntdirs cat

echo '-- many mounted(2 of 4) --'
_mntdirs="/mnt1 /mnt3"
cat $filesdir/mount-2.log | get-rmntdirs cat

echo '-- include unmounted(3 of 4, 1 unmounted) --'
_mntdirs="/mnt1 /mnt4 /mnt3"
cat $filesdir/mount-2.log | get-rmntdirs cat

