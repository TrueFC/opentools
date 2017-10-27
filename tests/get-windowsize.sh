#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. $OPENTOOLSDIR/include/common.inc
. $OPENTOOLSLIBDIR/subc
. $OPENTOOLSLIBDIR/xc
_debug=true
_debug_mode=module
_debug=false
_debug_level=1
_debug_commands="get-windowsize"
_debug_functions="get-windowsize"
_dry_run=false

get-windowsize
