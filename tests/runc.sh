#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. $OPENTOOLSDIR/include/common.inc
. $OPENTOOLSLIBDIR/subc
_debug=true
_debug_mode=module
_debug=false
_debug_level=1
_debug_commands="runc"
_debug_functions="runc"
_dry_run=true

echo "DEBUG_COMMANDS='$DEBUG_COMMANDS'"

_mntdir=/mnt
SRCDIR=/usr/src

runc chroot $_mntdir /bin/sh -c \"cd $SRCDIR\; \
	if ! runc make buildworld\; then \
	error \\\"'make buildworld' failed with rtcode:$?\\\"\; \
	fi\; \
	if ! runc make installworld\; then \
	error \\\"'make installworld' failed with rtcode:$?\\\"\; \
	fi\;\"

_dry_run=false
chroot $_mntdir /bin/sh -c "runc(){
	if $_dry_run; then
		echo \"# \$@\"
	else
		eval \"\$@\"
	fi
	}
	runc cd $SRCDIR
	if ! runc echo make buildworld; then
		error \"'make buildworld' failed with rtcode:$?\"
	fi
	if ! runc echo make installworld; then
		error \"'make installworld' failed with rtcode:$?\"
	fi"
