#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. $OPENTOOLSDIR/include/common.inc
. $OPENTOOLSINCDIR/sys.inc
. $OPENTOOLSLIBDIR/subc
. $OPENTOOLSLIBDIR/osc

_debug=true
_debug_mode=module
_debug_commands=automm
_debug_functions=automm
_debug_level=1
_dry_run=true

putdebug 1 automm COMMAND_NAME

_mmrootdir=../tmp/mergemaster
mkdir -p $_mmrootdir/etc
cp -f /etc/rc.* /etc/*.conf $_mmrootdir/etc

echo "-- exclude make.conf, resolv.conf rc.conf --"
automm
