#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../lib/subc

_debug=true
_debug_level=1

options=$(echo "-nvxmtbedfc" | expand-options "BFhlnvr" "bdfm")
#echo '$?='$?
if [ $? -gt 0 ]; then
	error $(basename $0) "illegal option \"$options\""
else
	putdebug 1 $(basename $0) options
fi
