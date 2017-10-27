#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../include/common.inc
. ../lib/subc

_debug=false
_debug_level=1
filesdir=../tmp/files

echo '-- actual mounted --'
cat $filesdir/mount.log | get-mntdir

echo '-- No mounted --'
cat $filesdir/mount.log | get-mntdir cat

echo '-- 1 mounted --'
cat $filesdir/mount-1.log | get-mntdir cat

echo '-- many mounted --'
cat $filesdir/mount-2.log | get-mntdir cat

