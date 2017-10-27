#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../lib/subc

check-xpkgs()
{
	if ! echo "$1" | \
		egrep -q '^[^:[:space:]]+:[^:[:space:]]+:[^:[:space:]]+:[^:[:space:]]+.*$'; then
		return 1
	else
		return 0
	fi
}

pass-xepkgs()
{
	local __n=1 __datum __nxepkg=4 __xepkg="" __xepkgs="" 

	IFS=':'
	for __datum in $*; do
		if echo "${__datum}" | egrep -q '^[[:space:]]*$'; then
			continue
		fi
		putdebug 1 pass-xepkgs __n __datum
		if [ ${__n} -ge ${__nxepkg} ]; then
			__xepkg="${__xepkg}:\"`echo ${__datum} | \
                     sed -Ee 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`\""
			putdebug 1 pass-xepkgs __xepkg
			if check-xpkgs "${__xepkg}"; then
				__xepkgs=`printf "%s\n%s\n" "${__xepkgs}" "${__xepkg}"`
				__xepkg=""
			else
				error pass-xepkgs "wrong xepkg list format"
			fi
			: $((__n = 1))
		else
			putdebug 1 pass-xepkgs:1 __xepkg
			if [ -z "${__xepkg}" ]; then
				__xepkg="`echo ${__datum} | \
                         sed -Ee 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`"
				putdebug 1 pass-xepkgs:2 __xepkg
			else
				__xepkg="${__xepkg}:`echo ${__datum} | \
                         sed -Ee 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`"
			fi
			putdebug 1 pass-xepkgs:3 __xepkg
			: $((__n += 1))
		fi
	done
	echo "${__xepkgs}"
}

_debug=true
_debug_level=1

pass-xepkgs c-support:1.22:lang:"Basic single-file add-ons for editing C code" \
	cc-mode:1.45:lang:"C,C++,Objective-C,Java,CORBA IDL,Pike and AWK language support" \
	debug:1.18:devel:"GUD, gdb, dbx debugging support"
