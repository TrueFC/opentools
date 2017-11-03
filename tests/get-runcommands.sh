#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. $OPENTOOLSDIR/include/common.inc
. $OPENTOOLSLIBDIR/subc
_debug=true
_debug_mode=module
_debug=false
_debug_level=1
_debug_commands="get-runcommands"
_debug_functions="get-runcommands"
_dry_run=false

echo '-- "foo,foo1,foo2,foo3,foo4" --'
get-runcommands "foo,foo1,foo2,foo3,foo4"

echo '-- "foo foo1 foo2 foo3 foo4" --'
get-runcommands "foo foo1 foo2 foo3 foo4"

echo '-- "foo,foo1 foo2 foo3,foo4" --'
get-runcommands "foo,foo1 foo2 foo3,foo4"

echo '-- "  foo, foo1 foo2 ,foo3   foo4 " --'
get-runcommands "  foo, foo1 foo2 ,foo3   foo4 "

echo '-- "  foo " --'
get-runcommands "  foo "
