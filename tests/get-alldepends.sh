#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. $OPENTOOLSDIR/include/common.inc
. $OPENTOOLSDIR/include/ports.inc
. $OPENTOOLSLIBDIR/subc
. $OPENTOOLSLIBDIR/portsc

_debug=true
_debug_mode=module
_debug=false
_debug_level=1
_debug_commands="get-alldepends"
_debug_functions="get-alldepends"
_dry_run=false
_dry_run=true

echo "DEBUG_COMMANDS='$DEBUG_COMMANDS'"

echo '-- "japanese/xemacs-canna" --'
export PORTSDIR=/var/ports/jdtpkx
get-alldepends japanese/xemacs-canna
