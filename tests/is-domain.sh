#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../lib/subc

_debug=false
_debug_level=1

__host=bhyc
#__host=openedu.org
if is-domain "${__host}"; then
	msg is-domain "\"${__host}\" is domain name"
else
	msg is-domain "\"${__host}\" is *NOT* domain name"
fi
