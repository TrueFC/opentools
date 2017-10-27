#!/bin/sh
#-*- tab-width: 8; -*-
# ex:ts=8
#
# Copyright (c) 2016 Kazuhiko Kiriyama <kiri@OpenEdu.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#

. ${OPENTOOLSINCDIR:=${OPENTOOLSDIR:=..}/include}/common.inc
. $OPENTOOLSINCDIR/ports.inc

. $OPENTOOLSLIBDIR/subc
. $OPENTOOLSLIBDIR/portsc


main()
{
	local	__function__=main

	globalize

	while [ $# -gt 0 ] ; do
		case $1 in
		-d|--debug-mode=*)
			option=$1
			case $option in
			-d)
				shift
				case $1 in
				-*)
					error "need value for $option"
					;;
				esac
				_debug_mode=$1
				;;
			--debug-mode=*)
				_debug_mode=${option#*=}
				;;
			esac
			case $_debug_mode in
			module)
				_debug_level=1
				;;
			[0-9]*)
				_debug=true
				_debug_mode=level
				_debug_level=$1
				;;
			*)
				error "illegal debug mode '$_debug_mode'"
				;;
			esac
			;;
		--debug-commands=*)
			_debug_commands="${1#*=}"
			;;
		--debug-functions=*)
			_debug_functions="${1#*=}"
			;;
		-h)
			usage -s
			;;
		--help)
			usage -l
			;;
		-n|--dry-run)
			_dry_run=true
			;;
		-t|--target-portsdir=*)
			option=$1
			case $option in
			-t)
				shift
				case $1 in
				-*)
					error "need value for $option"
					;;
				esac
				target_portsdir=$1
				;;
			--target-portsdir=*)
				target_portsdir=${option#*=}
				;;
			esac
			;;
		-[a-zA-Z]*)
			options=$(echo "$1" | expand-options "hn" "dt")
			if [ $? -gt 0 ]; then
				error "illegal option \"$options\""
			fi
			shift
			set -- $options "$@"
			continue
			;;
		-*)
			error "illegal option \"$1\""
			;;
		*)
			break
			;;
		esac
		shift
	done

	initialize "$@"

	putdebug 1 0 portsdir
	for category in $(get-categories $portsdir); do
		if [ ! -e $newportsdir/$category ]; then
			runc ln -shf $target_portsdir/$category $newportsdir/$category
		else 
			for port in $(ls $portsdir/$category); do
				if [ ! -e $newportsdir/$category/$port ]; then
					runc ln -shf $target_portsdir/$category/$port $newportsdir/$category/$port
				fi
			done
		fi
	done
	pdir=""
	for path in $(get-categories -x $portsdir); do
		dir=$(dirname $path)
		if [ -z "$pdir" ]; then
			pdir=$(echo $dir | sed -Ee 's/\./\\\\./g')
		fi
		file=$(basename $path)
		putdebug 8 0 path dir pdir
		if [ "$dir" = "." ]; then
			if [ ! -e $newportsdir/$file ]; then
				runc ln -shf $target_portsdir/$file $newportsdir/$file
			fi
		else
			if [ -d $newportsdir/$dir ]; then
				if [ ! -e $newportsdir/$dir/$file ]; then
					runc ln -shf $target_portsdir/$dir/$file $newportsdir/$dir/$file
				fi
			elif [ -d $newportsdir/$(dirname $dir) ]; then
				putdebug 9 0 dir pdir
				if ! echo $dir | egrep -qe "^$pdir"; then
					runc ln -shf $target_portsdir/$dir $newportsdir/$dir
					pdir=$dir
				else
					continue
				fi
			fi
		fi
	done

	finalize

	return 0
}

globalize()
{
	target_portsdir=$PORTSREPO
}

initialize()
{
	local	__function__=initialize

	check-debug
	if [ $# -lt 1 ]; then
		error "at least 1 path speciied"
	elif [ $# -lt 2 ]; then
		portsdir=$target_portsdir
		newportsdir=$1
	elif [ $# -lt 3 ]; then
		portsdir=$1
		newportsdir=$2
	else
		error "too more paths speciied"
	fi
	if [ -z "$VERSION" ]; then
		warn "version not defined"
	fi
	putdebug -s 3 0 portsdir newportsdir _debug _debug_level _dry_run
}

finalize()
{
}

usage()
{
	case $1 in
	-s)
		cat <<- EOF
		Usage: $COMMAND_NAME [-nh] [-d <debug mode>] [--debug-commands=<debug commands>] [--debug-functions=<debug functions>] [-t dir] [--help] path [path]
		EOF
		;;
	-l)
		cat <<- EOF
		OpenTools $PROGRAM_NAME $VERSION, cretare specific ports tree clone.
		
		Usage: $COMMAND_NAME [-nh] [-d <debug mode>] [--debug-commands=<debug commands>] [--debug-functions=<debug functions>] [-t dir] [--help] path [path]
		  path is the specific ports tree prefix which say PORTSDIR in
		  bsd.port.mk. If two paths specifed, the first is the original and
		  the second is the new one where only specific ports were prepared
		  to be created.
		
		Options:
		  -h                           print short usage
		       --help                  print long usage(this help)
		  -d,  --debug-mode=<debug mode>
		                               debugging with <debug mode>. <debug mode>=number or
					       'module'. if 'module' <debug level)=1, number
					       <debug level)=number.
		  --debug-commands=<debug commands>
		                               if <debug mode>='module', debug only on <debug commands>.
		                               default <debug commands>=DEBUG_COMMANDS
		  --debug-functions=<debug functions>
		                               if <debug mode>='module', debug only on <debug functions>
		                               of <debug commands>. 
					       default <debug functions>=DEBUG_FUNCTIONS
		  -n,  --dry-run               do not execute but show commands
		  -t,  --target-portsdir=dir   user target ports directory with "dir"
		                               instead of PORTSDIR
		EOF
		;;
	esac
	exit 0
}

main "$@" || exit 1
