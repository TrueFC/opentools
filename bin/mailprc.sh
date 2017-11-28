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
. $OPENTOOLSINCDIR/mail.inc

. $OPENTOOLSLIBDIR/subc


main()
{
	local	__function__=main

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
		-p|--protocol=*)
			option=$1
			case $option in
			-p)
				shift
				case $1 in
				-*)
					error "need value for $option"
					;;
				esac
				_protocol=$1
				;;
			--protocol=*)
				_protocol=${option#*=}
				;;
			esac
			;;
		-u|--user=*)
			option=$1
			case $option in
			-u)
				shift
				case $1 in
				-*)
					error "need value for $option"
					;;
				esac
				_user=$1
				;;
			--user=*)
				_user=${option#*=}
				;;
			esac
			;;
		-v|--verbose-output)
			_verbose_output=true
			;;
		-[a-zA-Z]*)
			options=$(echo "$1" | expand-options "hnv" "dpu")
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

	putdebug -s 1 0 _debug _debug_level _dry_run \
		_protocol _local_mailpath _user _verbose_output

	initialize "$@"

	runc imget $_imget_args
	mails=$(ls $_inboxdir | egrep '^[[:digit:]]+$')
	for mail in $mails; do
		if runc formail -ds procmail \< $_inboxdir/$mail; then
			runc rm -f $_inboxdir/$mail
		else
			warn "mail content does not correctlly processed: \"$mail\""
		fi
	done

	finalize

	return 0
}

initialize()
{
	local	__function__=initialize

	check-debug
	if [ -z "$_protocol" ]; then
		error "protocol must be specified"
	else
		if echo $_protocol | egrep -q ':'; then
			_local_mailpath=${_protocol#*:}
			_protocol=${_protocol%%:*}
		fi
	fi
	if [ $# -lt 1 ]; then
		putdebug 3 0 _protocol
		case $_protocol in
		local)
			;;
		*)
			if [ -z "$_server" -o -z "$_user" ]; then
				error "host or user not specified"
			fi
		esac
	elif [ $# -lt 2 ]; then
		if [ -z "$_user" -o -z "$_protocol" ]; then
			error "\"user\" or \"protocol\" not specified"
		fi
		_server=$1
	else
		error "too more arguments:\"$*\" specied"
	fi
	putdebug 1 0 _protocol
	case $_protocol in
	local)
		if [ -z "$_local_mailpath" ]; then
			_imget_args="--src=local"
		else
			if test -d $_local_mailpath && ! check-mailfolder -q $_local_mailpath; then
				error "not the qmail maildir:$_local_mailpath"
			fi
			_imget_args="--src=local:$_local_mailpath"
		fi
		putdebug 2 0 _user _server
		if [ -n "$_user" -o -n "$_server" ]; then
			warn "local fetching. user or server ignored"
		fi
		;;
	pop)
		_imget_args="--src=$_protocol:$_user@$_server --quiet=on --keep=0"
		;;
	esac
	if [ -z "$_inboxdir" ]; then
		_inboxdir=$HOME/Mail/inbox
	fi
	if [ -z "$VERSION" ]; then
		warn "version not defined"
	fi
}

finalize()
{
	unset-exports
}

check-mailfolder()
{
	local	__folder					\
		__folder_type=mbox				\
		__function__=check-mailfolder

	while [ $# -gt 0 ]; do
		case $1 in
		-q)
			__folder_type=qmail
			;;
		*)
			break
			;;
		esac
		shift
	done
	__folder=$1
	putdebug 2 1 __folder_type
	case $__folder_type in
	mbox)
		if [ -f $__folder ]; then
			return 0
		else
			return 1
		fi
		;;
	qmail)
		putdebug 2 2 _im_conf_file
		if [ -n "$_im_conf_file" ]; then
			if [ -d $__folder/cur -a -d $__folder/new -a -d $__folder/tmp ]; then
				if egrep -q '^MBoxStyle=qmail[[:space:]#]*.*$' $_im_conf_file; then
					return 0
				else
					error "not set qmail in $_im_conf_file"
				fi
			else
				error "not qmail maildir:$__folder"
			fi
		else
			error "im config file not found"
		fi
		;;
	esac
}
	
usage()
{
	case $1 in
	-s)
		cat <<- EOF
		Usage: $COMMAND_NAME [-hnv] [-d <debug mode>] [--debug-commands=<debug commands>] [--debug-functions=<debug functions>] [-p <protocol>] [-u <user>] [--help] [<host>]
		EOF
		;;
	-l)
		cat <<- EOF
		OpenTools $PROGRAM_NAME $VERSION, a mail fetch and deliver to folders program(MDA).
		
		Usage: $COMMAND_NAME [-hnv] [-d <debug mode>] [--debug-commands=<debug commands>] [--debug-functions=<debug functions>] [-p <protocol>] [-u <user>] [--help] [<host>]
		  Fetch mails from <user> of mail server <host> by specified <protpcol> and
		  deliver to respective folder described in 'procmailrc'. Mail fetchs by imget
		  and delivery by procmail. 
		
		Options:
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
		  -p,--protocol=<protocol>
		                <protocol> for POP or IMAP. each <protocol> should be specified
		                by 'local[:mailbox|:maildir]' or 'pop[/APOP|/RPOP|/POP]'
		  -u,--user=<user>
		                <user> belong to POP server <host>
		  -v,--verbose-output
		                running with verbose output
		EOF
		;;
	esac
	exit 0
}

main "$@" || exit 1
