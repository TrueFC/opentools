#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. $OPENTOOLSDIR/include/common.inc
. $OPENTOOLSLIBDIR/subc
_debug=true
_debug_mode=module
_debug=false
_debug_level=1
_debug_commands="sortg"
_debug_functions="sortg"
_dry_run=true

echo "DEBUG_COMMANDS='$DEBUG_COMMANDS'"

echo '-- img:foo img1:bar img:foo1 img2:baz img1:bar1 img1:bar2 --'
sortg img:foo img1:bar img:foo1 img2:baz img1:bar1 img1:bar2

echo '-- img1:{bar{0,1,2/{bar2{1,2,3}}}} img:{foo{,1,2/{foo2{1,2}}}} img2:baz/{baz{12/{bar2{1,2}}}} --'
sortg img1:{bar{0,1,2/{bar2{1,2,3}}}} img:{foo{,1,2/{foo2{1,2}}}} img2:baz/{baz{12/{bar2{1,2}}}}

