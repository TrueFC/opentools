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
. $OPENTOOLSLIBDIR/xepkgsc


main()
{
	local	__function__=main

	while [ $# -gt 0 ]; do
		case $1 in
		-c|--copy-distinfo)
			_mode=copy
			;;
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
		-i|--info-mode)
			_mode=info
			;;
		-n|--dry-run)
			_dry_run=true
			;;
		-[a-zA-Z]*)
			options=$(echo "$1" | expand-options "chin" "d")
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

	case $_mode in
	info)
		xepkgs_all=$(cat $OPENTOOLSDATADIR/xepkgs_all.names)
		xepkgs_latin1=$(cat $OPENTOOLSDATADIR/xepkgs_latin1.names)
		xepkgs_mule=$(cat $OPENTOOLSDATADIR/xepkgs_mule.names)
		xepkgs_exclude=$(printf '%s\n%s\n' "$xepkgs_latin1" "$xepkgs_mule")
		IFS=$'\n'
		for xepkg_exclude in $xepkgs_exclude; do
			xepkgs_all=$(echo "$xepkgs_all" | grep -v "$xepkg_exclude")
		done
		unset IFS
		echo "$xepkgs_all"
		;;
	copy)
		IFS=$'\n'
		for xepkg in $(get-xepkgs $_xepkg_file); do
			portname=${xepkg%%:*};    xepkg=${xepkg#*:};
			portversion=${xepkg%%:*}; xepkg=${xepkg#*:};
			category=${xepkg%%:*};    xepkg=${xepkg#*:};
			case $_xepkg_name in
			ports)
				distinfo_path=$category/$portname/distinfo
				;;
			*)
				distinfo_path=$category/xepkg-$portname/distinfo
				;;
			esac
			runc $CP $_src_path/$distinfo_path $_dest_path/$distinfo_path
		done
		unset IFS
		;;
	*)
		break
		;;
	esac

	finalize

	return 0
}

initialize()
{
	local	__function__=initialize

	putdebug 1 1 _mode
	check-debug
	case $_mode in
	info)
		if [ $# -lt 1 ]; then
			error "specify \"xepkg_name\""
		elif [ $# -lt 2 ]; then
			_xepkg_name=$1
			_portsdir=$PORTSDIR
		elif [ $# -lt 3 ]; then
			_xepkg_name=$1
			_portsdir=$3
		else
			error "exist extra arguents"
		fi
		case $_xepkg_name in
		latin1|mule|misc)
			;;
		*)
			error "wrong distinfo name:\"$_distinfo\""
			;;
		esac
		_xepkg_file=$OPENTOOLSDATADIR/xepkgs.$_xepkg_name
		;;
	copy)
		if [ $# -lt 2 ]; then
			error "specify \"xepkg_name\" or \"src_path\""
		elif [ $# -lt 3 ]; then
			_xepkg_name=$1
			_src_path=$2
			_dest_path=$PORTSDIR
		elif [ $# -lt 4 ]; then
			_xepkg_name=$1
			_src_path=$2
			_dest_path=$3
		else
			error "exist extra arguents"
		fi
		CP=$(cpcmd $_src_path)
		case $_xepkg_name in
		ports)
			_xepkg_file=$OPENTOOLSDATADIR/xemacs.$_xepkg_name
			;;
		*)
			_xepkg_file=$OPENTOOLSDATADIR/xepkgs.$_xepkg_name
			;;
		esac
		;;
	esac
	if [ -z "$VERSION" ]; then
		warn "version not defined"
	fi
	putdebug 1 2 CP _xepkg_name _src_path _portsdir
}


finalize()
{
	unset-exports
}

usage()
{
	case $1 in
	-s)
		cat <<- EOF
		Usage: $COMMAND_NAME [-nhi] [-d <debug mode>] [--debug-commands=<debug commands>] [--debug-functions=<debug functions>] <name>
		       $COMMAND_NAME [-nhc] [-d <debug mode>] [--debug-commands=<debug commands>] [--debug-functions=<debug functions>] <name> <src> [<dest>]
		EOF
		;;
	-l)
		cat <<- EOF
		OpenTools $PROGRAM_NAME $VERSION, get XEmacs packages informations.
		
		Usage: $COMMAND_NAME [-nhi] [-d <debug mode>] [--debug-commands=<debug commands>] [--debug-functions=<debug functions>] <name>
		       $COMMAND_NAME [-nhc] [-d <debug mode>] [--debug-commands=<debug commands>] [--debug-functions=<debug functions>] <name> <src> [<dest>]
		
		Common:
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
		
		Show xepkgs info mode:
		  -i,  --info-mode             show portnames of xepkg-<name>
		
		Copy xepkgs ports distinfos mode:
		  -c,  --copy-distinfo         copy distinfos of xepkg-<name> to <dir>
		                               which considered as \$PORTSDIR
		EOF
		;;
	esac
	exit 0
}

main "$@" || exit 1
