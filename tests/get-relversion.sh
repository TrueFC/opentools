#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../include/common.inc
. ../lib/subc
. ../lib/osc

_debug=true
_debug_level=1

OSName=FreeBSD
OSVersion=CURRENT

get-versions
echo "$_releng_info"
echo "get-relversion:\"$(get-relversion)\""
echo "get-relevel:\"$(get-relevel)\""
