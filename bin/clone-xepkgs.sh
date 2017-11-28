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
		-f|--force-create)
			_force_create=true
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
		-m|--metaport-only)
			_metaport_only=true
			;;
		-o|--option-metaport)
			_option_metaport=true
			;;
		-p|--ports-only)
			_ports_only=true
			;;
		-[a-zA-Z]*)
			options=$(echo "$1" | expand-options "fhnmop" "d")
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

	putdebug -s 8 0 _ports_only _metaport_only
	if ! $_ports_only; then
		create-metaport
		_xepkgs=$(poped _xepkgs)
	fi
	if ! $_metaport_only; then
		echo "$_xepkgs" | \
		while read xepkg; do
			portname=${xepkg%%:*};	  xepkg=${xepkg#*:};
			portversion=${xepkg%%:*}; xepkg=${xepkg#*:};
			category=${xepkg%%:*};	  xepkg=${xepkg#*:};
			comment=$xepkg
			destdir=$_portsdir/$category/xepkg-$portname
			putdebug 2 main:2 portname portversion category destdir
			if [ -h $_portsdir/$category ]; then
				runc rm -f $_portsdir/$category
			fi
			if [ ! -d $destdir -o $_force_create ]; then
				if $_force_create; then
					runc rm -rf $destdir
				fi
				runc mkdir -p $destdir
				for file in Makefile pkg-descr; do
					runc sed -E \
						-e "s/%%PORTNAME%%/$portname/g" \
						-e "s/%%PORTVERSION%%/$portversion/g" \
						-e "s/%%CATEGORY%%/$category/g" \
						-e "s@%%COMMENT%%@$comment@g" \
						$_templatedir/xepkgs/port/$file \> $destdir/$file
				done
			fi
		done
	fi

	finalize

	return 0
}

initialize()
{
	local	__function__=initialize				\
		__xepkgs_file					\
		__xepkg_names=""

	check-debug
	putdebug 1 0 _debug _debug_level _dry_run _option_metaport _xepkgs_file
	if [ $# -lt 1 ]; then
		error "xepkg data file not speciied"
	elif [ $# -lt 2 ]; then
		__xepkgs_file=$(get-xepkgsfile $1)
		_xepkgs=$(get-xepkgs -f $__xepkgs_file)
		_portsdir=$(get-portsdir $PORTSDIR)
	elif [ $# -lt 3 ]; then
		__xepkg_file=$(get-xepkgsfile $1)
		_all_xepkgs=$(get-xepkgs -f $__xepkgs_file)
		if [ -d $2 ]; then
			_xepkgs="$_all_xepkgs"
		else
			_xepkgs=$(get-xepkgs -n $2)
		fi
		_portsdir=$(get-portsdir $2)
	else
		__xepkgs_file=$(get-xepkgsfile $1)
		putdebug 7 initialize:1 __xepkg_file
		_all_xepkgs=$(get-xepkgs -f $__xepkgs_file)
		putdebug 7 initialize:2 _all_xepkgs
		shift
		while [ $# -gt 1 ]; do
			if [ -z "$__xepkg_names" ]; then
				__xepkg_names=$1
			else
				__xepkg_names="$__xepkg_names $1"
			fi
			shift
		done
		putdebug 8 initialize:1 __xepkg_names
		if [ -d $1 ]; then
			_xepkgs=$(get-xepkgs -n $__xepkg_names)
		else
			_xepkgs=$(get-xepkgs -n $__xepkg_names $1)
		fi
		_portsdir=$(get-portsdir $1)
		putdebug 8 initialize:2 _portsdir 
	fi
	if ! ($_ports_only || $_metaport_only); then
		_ports_only=true
	fi
	if [ -z "$VERSION" ]; then
		warn "version not defined"
	fi
}

check-xepkg()
{
	if ! echo "$_all_xepkgs" | egrep -q "^$1:"; then
		return 1
	else
		return 0
	fi
}

create-metaport()
{
	local	__category					\
		__comment					\
		__descs=""					\
		__destdir					\
		__function__=create-metaport			\
		__group_name					\
		__insert_stuffs					\
		__option					\
		__options=""					\
		__options_default=""				\
		__options_group=""				\
		__pkgnameprefix='xepkg-'			\
		__portname					\
		__portversion					\
		__run_depends=""				\
		__templatedir_makefile				\
		__xepkg						\
		__xepkg_metaport				\
		__xepkgs="$(poped _xepkgs)"			\
		__xepkgs_category

	__xepkg_metaport="$(pop _xepkgs)"
	putdebug 3 0 _xepkgs __xepkg_metaport
	if $_option_metaport; then
		__templatedir_makefile=$_templatedir/xepkgs/metaport.options
		for __category in $(get-categories); do
			__xepkgs_category=$(echo "$__xepkgs" | egrep "^[^:]+:[^:]+:$__category:" | sort)
			putdebug 5 create-metaport:1 __xepkgs_category
			if [ -z "$__xepkgs_category" ]; then
				continue
			fi
			__group_name=$(toupper -n $__category)
			if [ -z "$__options_group" ]; then
				__options_group=$(printf 'OPTIONS_GROUP=\t\t\t%s' $__group_name)
			else
				__options_group=$(printf '%s\n\nOPTIONS_GROUP+=\t\t\t%s'  "$__options_group" \
																			$__group_name)
			fi
			__group_comment=$(get-categorycoment $__category)
			IFS=$'\n'
			for __xepkg in $__xepkgs_category; do
				__portname=${__xepkg%%:*};    __xepkg=${__xepkg#*:};
				__portversion=${__xepkg%%:*}
				__comment=$(eval echo ${__xepkg##*:})
				__option=$(toupper -n ${__portname})
				if [ -z "$__options_default" ]; then
					__options_default=$(printf 'OPTIONS_DEFAULT=\t\t%s \\' $__option)
				else
					__options_default=$(printf '%s\n\t\t\t\t\t\t%s \\' "$__options_default" $__option)
				fi
				if [ -z "$__options" ]; then
					__options=$(printf 'OPTIONS_GROUP_%s=\t%s \\' $__group_name $__option)
				else
					__options=$(printf '%s\n\t\t\t\t\t\t%s \\' "$__options" $__option)
				fi					
				if [ -z "$__descs" ]; then
					__descs=$(printf '%s_DESC=\t\t%s\n%s_DESC=\t\t%s\n'   $__group_name "$__group_comment" $__option "$__comment")
				else
					__descs=$(printf '%s\n%s_DESC=\t\t%s\n' "$__descs" $__option "$__comment")
				fi					
				if [ -z "$__run_depends" ]; then
					__run_depends=$(printf '%s_RUN_DEPENDS=\t%s\n'	  $__option "$__pkgnameprefix$__portname\\$PKGNAMESUFFIX>=$__portversion:\\$PORTSDIR/$__category/xepkg-$__portname")
				else
					__run_depends=$(printf '%s\n%s_RUN_DEPENDS=\t%s\n'   "$__run_depends" $__option "$__pkgnameprefix$__portname\\$PKGNAMESUFFIX>=$__portversion:\\$PORTSDIR/$__category/xepkg-$__portname")
				fi
			done
			unset IFS
			__options=${__options% \\}
			__options_group=$(printf '%s\n%s\n%s\n%s\n'    "$__options_group" "$__options" "$__descs" "$__run_depends")
			__options=""
			__descs=""
			__run_depends=""
		done
		__options_default=${__options_default% \\}
		__insert_stuffs=$(printf '%s\n\n%s\n' "$__options_default" "$__options_group")
	else
		__templatedir_makefile=$_templatedir/xepkgs/metaport
		IFS=$'\n'
		for __xepkg in $__xepkgs; do
			__portname=${__xepkg%%:*};    __xepkg=${__xepkg#*:};
			__portversion=${__xepkg%%:*}; __xepkg=${__xepkg#*:};
			__category=${__xepkg%%:*};    __xepkg=${__xepkg#*:};
			if [ -z "$__run_depends" ]; then
				__run_depends=$(printf 'RUN_DEPENDS=\t%s\n' "$__pkgnameprefix$__portname\\$PKGNAMESUFFIX>=$__portversion:\\$PORTSDIR/$__category/xepkg-$__portname \\\\")
			else
				__run_depends=$(printf '%s\n\t\t%s\n' "$__run_depends" "$__pkgnameprefix$__portname\\$PKGNAMESUFFIX>=$__portversion:\\$PORTSDIR/$__category/xepkg-$__portname \\\\")
			fi
			putdebug 2 main:2 __portname __portversion __category __destdir
		done
		unset IFS
		__insert_stuffs=${__run_depends% \\}
		putdebug 4 0 __run_depends
	fi
	putdebug -s 6 0 __insert_stuffs
	__portname=${__xepkg_metaport%%:*};    __xepkg_metaport=${__xepkg_metaport#*:};
	__portversion=${__xepkg_metaport%%:*}; __xepkg_metaport=${__xepkg_metaport#*:};
	__category=${__xepkg_metaport%%:*};    __xepkg_metaport=${__xepkg_metaport#*:};
	__comment=$__xepkg_metaport
	__destdir=$_portsdir/$__category/xepkg-$__portname
	putdebug -s 5 create-metaport:2 __portname __portversion __category __destdir
	if [ -h $_portsdir/$__category ]; then
		runc rm -f $_portsdir/$__category
	fi
	if [ ! -d $__destdir -o $_force_create ]; then
		if $_force_create; then
			runc rm -rf $__destdir
		fi
		runc mkdir -p $__destdir
		runc sed -E -e "s@%%COMMENT%%@$__comment@g" \
			$__templatedir_makefile/pkg-descr \> $__destdir/pkg-descr
		__comment=$(eval echo $__comment)
		__makefile=$(sed -E \
				-e "s/%%PORTNAME%%/$__portname/g" \
				-e "s/%%PORTVERSION%%/$__portversion/g" \
				-e "s/%%CATEGORY%%/$__category/g" \
				-e "s@%%COMMENT%%@$__comment@g" \
				$__templatedir_makefile/Makefile)
		runc splice -r -a 'RUN_DEPENDS=' __makefile __insert_stuffs \> $__destdir/Makefile
	fi
}

get-categories()
{
	cat $OPENTOOLSDATADIR/FreeBSD_ports_category | cut -d : -f 1
}

get-categorycoment()
{
	cat $OPENTOOLSDATADIR/FreeBSD_ports_category | egrep "^$1:" | cut -d : -f 2
}

get-portsdir()
{
	local	__function__=get-portsdir

	if [ -d $1 ]; then
		echo $1
	else
		if [ -d $PORTSDIR ]; then
			warn "set PORTSDIR=\"$PORTSDIR\""
			echo $PORTSDIR
		else
			error "PORTSDIR:\"$PORTSDIR\" not found"
		fi
	fi
}

get-xepkgs()
{
	local	__data						\
		__datum						\
		__function__=get-xepkgs				\
		__mode=nonexistent				\
		__xepkg=""					\
		__xepkgs=""					\
		__xepkg_name					\
		__xepkgs_file					\
		__xepkgs_names

	while [ $# -gt 0 ]; do
		case $1 in
		-f)
			__mode=input
			shift
			__xepkgs_file=$1
			;;
		-n)
			__mode=grep
			;;
		*)
			break
			;;
		esac
		shift
	done
	case $__mode in
	input)
		putdebug 7 get-xepkgs:1 __xepkgs_file
		__data=$(cat $__xepkgs_file)
		putdebug 7 get-xepkgs:2 __data
		IFS=$'\n'
		for __datum in $__data; do
			putdebug 1 0 __datum
			if echo $__datum | egrep -q '\\$'; then
				__xepkg="$__xepkg$(echo $__datum | \
					sed -Ee 's/^[[:space:]]*//' -e 's/[[:space:]]*\\\\$//')"
			else
				__xepkg="$__xepkg\"$(echo $__datum | \
					sed -Ee 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')\""
				if [ -z "$__xepkgs" ]; then
					__xepkgs=$(printf "%s\n" "$__xepkg")
				else
					__xepkgs=$(printf "%s\n%s\n" "$__xepkgs" "$__xepkg")
				fi
				__xepkg=""
			fi
		done
		unset IFS
		;;
	grep)
		__xepkgs_names=$*
		for __xepkg_name in $__xepkgs_names; do
			if check-xepkg $__xepkg_name; then
				if [ -z "$__xepkgs" ]; then
					__xepkgs=$(echo "$_all_xepkgs" | egrep "^$__xepkg_name:")
				else
					__xepkg=$(echo "$_all_xepkgs" | egrep "^$__xepkg_name:")
					__xepkgs=$(printf '%s\n%s\n' "$__xepkgs" "$__xepkg")
				fi
			else
				warn "\"$__xepkg_name\" not found"
			fi
		done
		;;
	esac
	echo "$__xepkgs"
}

get-xepkgsfile()
{
	local	__function__=get-xepkgsfile

	if [ -f $1 ]; then
		echo $1
	else
		if [ -f $OPENTOOLSDATADIR/$1 ]; then
			echo $OPENTOOLSDATADIR/$1
		else
			error "\"$OPENTOOLSDATADIR/$1\" not found"
		fi
	fi
}

pass-xepkgs()
{
	local	__n=1						\
		__datum						\
		__function__=pass-xepkgs			\
		__nxepkg=4					\
		__xepkg=""					\
		__xepkgs=""

	IFS=':'
	for __datum in $*; do
		if echo "$__datum" | egrep -q '^[[:space:]]*$'; then
			continue
		fi
		putdebug 1 0 __n __datum
		if [ $__n -ge $__nxepkg ]; then
			__xepkg="$__xepkg:\"$(echo $__datum | \
		     sed -Ee 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')\""
			putdebug 1 0 __xepkg
			if check-xpkgs "$__xepkg"; then
				__xepkgs=$(printf "%s\n%s\n" "$__xepkgs" "$__xepkg")
				__xepkg=""
			else
				error "wrong xepkg list format"
			fi
			: $((__n = 1))
		else
			putdebug 1 pass-xepkgs:1 __xepkg
			if [ -z "$__xepkg" ]; then
				__xepkg="$(echo $__datum | \
			 sed -Ee 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
				putdebug 1 pass-xepkgs:2 __xepkg
			else
				__xepkg="$__xepkg:$(echo $__datum | \
			 sed -Ee 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
			fi
			putdebug 1 pass-xepkgs:3 __xepkg
			: $((__n += 1))
		fi
	done
	unset IFS
	echo "$__xepkgs"
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
		Usage: $COMMAND_NAME [-fhmnop] [-d <debug mode>] [--debug-commands=<debug commands>] [--debug-functions=<debug functions>] [--help] file [name ...] [path]
		EOF
		;;
	-l)
		cat <<- EOF
		OpenTools $PROGRAM_NAME $VERSION, clone XEmacs package ports.
		
		Usage: $COMMAND_NAME [-fhmnop] [-d <debug mode>] [--debug-commands=<debug commands>] [--debug-functions=<debug functions>] [--help] file [name ...] [path]
		  Clone XEmac package port under the PORTSDIR=path with the name described
		  in the xepkg data file. The xepkg data file is the data sheet listed
		  in which each xepkg port writed in a line PORTNAME, PORTVERSION, CATEGORY
		  and COMMENT separated with \":\" respectively. 

		  The names in the commainline would be assumed by ordinary ports names.
		  If you create a meta port, \"-m\" option must be specified.

		  If name is not specified, all xepkg ports in the file would be made.
		
		Options:
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
		  -f,  --force-create	       force create port. NOTE:existent port destroyed!
		  -h			       print short usage
		       --help		       print long usage(this help)
		  -m,  --metaport-only	       only create metaport
		  -n,  --dry-run	       do not execute but show commands
		  -o,  --option-metaport       create metaport with options
					       PORTNAME:PORTVERSION:CATEGORY:COMMENT listed
		  -p,  --ports-only	       only create ports (default)
		EOF
		;;
	esac
	exit 0
}

main "$@" || exit 1
