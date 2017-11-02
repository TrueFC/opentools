#!/bin/sh
#-*- tab-width: 8; -*-
# ex:ts=8
#
# Copyright (c) 2016 Kazuhiko Kiriyama <kiri@TrueFC.org>
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
. ${OPENTOOLSINCDIR:=${OPENTOOLSDIR:=..}/include}/misc.inc

. $OPENTOOLSLIBDIR/subc
. $OPENTOOLSLIBDIR/xc


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
		-[a-zA-Z]*)
			options=$(echo "$1" | expand-options "hn" "d")
			if [ $? -gt 0 ]; then
				error "illegal option '$options'"
			fi
			shift
			set -- $options "$@"
			continue
			;;
		-*)
			error "illegal option '$1'"
			;;
		*)
			break
			;;
		esac
		shift
	done

	initialize "$@"

	window_geometry=$(get-windowgeometry xemacs)
	putdebug 1 0 window_geometry
	application_name=$(get-windowdecoration -a xemacs)
	putdebug 1 1 application_name
	window_title=$(get-windowdecoration -t xemacs)
	putdebug 1 2 window_title
	runc xemacs     -name \"$application_name\" \
			-T \"$window_title\" \
			-geometry $window_geometry \&

	finalize

	return 0
}

globalize()
{
	position=RT
}

initialize()
{
	local	__function__=initialize

	check-debug
	! check-env -w && error "not in X-window"
	set-windowposition $position
}

finalize()
{
}
	
usage()
{
	case $1 in
	-s)
		cat <<- EOF
		Usage: $COMMAND_NAME [-hn] [-d <debug mode>] [--debug-commands=<debug commands>] [--debug-functions=<debug functions>] [--help]
		EOF
		;;
	-l)
		cat <<- EOF
		OpenTools $PROGRAM_NAME $VERSION, run XEmacs at right top location.
		
		Usage: $COMMAND_NAME [-hn] [-d <debug mode>] [--debug-commands=<debug commands>] [--debug-functions=<debug functions>] [--help]
		  Run XEmacs at left top location. Window size is chosen aoutomatically.

		Options:
		  -h            Print short usage
		     --help     Print long usage(this help)
		  -n,--dry-run  Do not execute but show commands  
		  -d,--debug-mode=<debug mode> Debugging with <debug mode>. <debug mode>=number or
		                'module'. if 'module',<debug level)=1.
		  --debug-commands=<debug commands> If <debug mode>='module', debug only on
		                <debug commands>. Default <debug commands>=DEBUG_COMMANDS.
		  --debug-functions=<debug functions> If <debug mode>='module', debug only on
		                <debug functions> of <debug commands>.
		                Default <debug functions>=DEBUG_FUNCTIONS
		EOF
		;;
	esac
	exit 0
}

main "$@" || exit 1