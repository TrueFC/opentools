#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../lib/subc

_debug=false
#_debug=true
_debug_level=1

newlined foo bar baz

newlined -n foo bar baz
