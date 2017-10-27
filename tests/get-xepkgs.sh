#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../lib/subc

get_xepkgs()
{
	local __data __datum __xepkg="" __xepkgs=""

	__data=`cat $1`
	IFS=$'\n'
	for __datum in ${__data}; do
		putdebug 1 get_xepkgs __datum
		if echo ${__datum} | egrep -q '\\$'; then
			__xepkg="${__xepkg}`echo ${__datum} | \
                     sed -Ee 's/^[[:space:]]*//' -e 's/[[:space:]]*\\\\$//'`"
		else
			__xepkg="${__xepkg}\"`echo ${__datum} | \
                     sed -Ee 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`\""
			__xepkgs=`printf "%s\n%s\n" "${__xepkgs}" "${__xepkg}"`
			__xepkg=""
		fi
	done
	echo "${__xepkgs}"
}

_debug=true
_debug_level=1

get_xepkgs ../data/xepkgs.latin1.20160417
