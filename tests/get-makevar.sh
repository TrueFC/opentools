#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../lib/subc
. ../lib/sysrc

_debug=false
_debug_level=1

for item in WRKDIRPREFIX PACKAGES DISTDIR BATCH WITH_NEW_XORG WITH_KMS DEFAULT_VERSIONS; do
	get-makevar /etc/make.conf $item
done
