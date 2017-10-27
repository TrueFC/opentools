#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../lib/subc

_debug=false
_debug_level=1

day=$(env LANG=C date)
from=$day
echo "h2n: \"$from\" ---> \"$(convdate h2n $from)\""
echo "h2t: \"$from\" ---> \"$(convdate h2t $from)\""
