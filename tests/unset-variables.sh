#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. $OPENTOOLSDIR/include/common.inc
. $OPENTOOLSLIBDIR/subc
_debug=true
_debug_mode=module
_debug=false
_debug_level=1
_debug_commands="unset-variables"
_debug_functions="unset-variables"
_dry_run=true

echo '-- "unset opentools" --'
unset-variables

echo '-- "unset bds" --'
unset-variables -b

echo '-- "unset all" --'
unset-variables -a
