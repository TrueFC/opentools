#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. $OPENTOOLSDIR/include/common.inc
. $OPENTOOLSLIBDIR/subc
_debug=true
_debug_mode=module
_debug=false
_debug_level=1
_debug_commands="get-space"
_debug_functions="get-space"
_dry_run=true

echo '-- get-space -k "#     " --'
get-space -k "#     "

echo '-- get-space -k "#     foo" --'
get-space -k "#     foo"
