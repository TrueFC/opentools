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
. $OPENTOOLSINCDIR/sys.inc

. $OPENTOOLSLIBDIR/subc


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
		-f|--force-execute)
			force_execute=true
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
		-p|--dest-host-port=*)
			option=$1
			case $option in
			-p)
				shift
				case $1 in
				-*)
					error "need value for $option"
					;;
				esac
				dest_host_port=$1
				;;
			--dest-host-port=*)
				dest_host_port=${1#*=}
				;;
			esac
			;;
		-r|--backup-rootdir=*)
			option=$1
			case $option in
			-r)
				shift
				case $1 in
				-*)
					error "need value for $option"
					;;
				esac
				backup_rootdir=$1
				;;
			--backup-rootdir=*)
				backup_rootdir=${1#*=}
				;;
			esac
			;;
		-[a-zA-Z]*)
			options=$(echo "$1" | expand-options "fhn" "dpr")
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

	if connected $dest_hostname; then
		sct $sct_args $src_path $dest_host:$dest_path
	fi

	finalize

	return 0
}

globalize()
{
	dest_host_port=""
	force_execute=false
	sct_args="-i"
}

usage()
{
	case $1 in
	-s)
		cat <<- EOF
		Usage: $COMMAND_NAME [-fhn] [-d <debug mode>] [--debug-commands=<debug commands>] [--debug-functions=<debug functions>] [-p <port>] [-r <dir>] [--help] <path> <host>[:<path>]
		EOF
		;;
	-l)
		cat <<- EOF
		OpenTools $PROGRAM_NAME $VERSION, a local directory tree to remote site copy tool.

		Usage: $COMMAND_NAME [-fhn] [-d <debug mode>] [--debug-commands=<debug commands>] [--debug-functions=<debug functions>] [-p <port>] [-r <dir>] [--help] <path> <host>[:<path>]

		  -d,--debug-mode=<debug mode>
		                Debugging with <debug mode>. <debug mode> is a digit or
		                'module'. If <debug mode> is 'module',<debug level)=1.
		  --debug-commands=<debug commands>
		                If <debug mode> is 'module', debug only on <debug commands>.
		                Default:<debug commands>=DEBUG_COMMANDS.
		  --debug-functions=<debug functions>
		                If <debug mode> is 'module', debug only on <debug functions> of
		                <debug commands>.
		                Default:<debug functions>=DEBUG_FUNCTIONS
		  -h            Print short usage
		  --help        Print long usage(this help)
		  -n,--dry-run  Do not execute but show commands  
		  -f,--force-execute
		                Force to copy
		  -i,--first-create
		                First create
		  -p,--dest-host-port=<port>
		                Host ssh port number
		  -r,  --backup-rootdir=<dir>
		                Root directory on backup site. <dir> should be the absolute path
		                name. All fies save under <dir>/<host>
		EOF
		;;
	esac
	exit 0
}

initialize()
{
	local	__function__=initialize

	check-debug
	if $force_execute; then
		sct_args="${sct_args}${sct_args:+ }-f"
	fi
	if [ -z "$1" -a -z "$2" ]; then
		error "src_path and dest_host must be specified"
	fi
	src_path=$1
	if echo $2 | egrep -q ':'; then
		dest_host=$(complete-hostform ${2%%:*})
		set-sshport ${2%%:*}
		dest_path=${2#*:}
		if ! echo $dest_path | egrep -q '^/'; then
			if [ -z "$backup_rootdir" ]; then
				error "specify backup site absolute path"
			else
				dest_path=$backup_rootdir/$dest_path
			fi
		fi
	else
		dest_host=$(complete-hostform $2)
		if [ -z "$backup_rootdir" ]; then
			dest_path=$DESTDIR
		else
			dest_path=$backup_rootdir/$HOST
		fi
	fi
	dest_hostname=${dest_host#*@}
	if [ -n "$dest_host_port" ]; then
		_ssh_port=$dest_host_port
	fi
	putdebug 1 0 _ssh_port
	backup_rootdir=$(echo $dest_path | sed -Ee 's|^(/[^/]+).*$|\1|')
	if [ -z "$VERSION" ]; then
		warn "version not defined"
	fi
}

finalize()
{
	rmtmpfile -a
}


main "$@" || exit 1
