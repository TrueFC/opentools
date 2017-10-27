#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../lib/subc

_debug=false
_debug_level=1

echo '-- "abcdef" -> "Abcdef" --'
capitalize abcdef

echo '-- "abcdef" -> "ABCdef" ("-h 3")--'
capitalize -h 3 abcdef

echo '-- "abcdef" -> "ABCdef" ("-b 3")--'
capitalize -b 3 abcdef
