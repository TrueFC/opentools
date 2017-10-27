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
. $OPENTOOLSINCDIR/misc.inc

. $OPENTOOLSLIBDIR/subc


main()
{
	local	__function__=main

	globalize

	while [ $# -gt 0 ] ; do
		case $1 in
		-a|--auto-backup)
			case $mode in
			reduction)
				error "not allow \"$mode\""
				;;
			esac
			mode=auto
			periodic_reduce_weekly=true
			periodic_reduce_monthly=true
			periodic_reduce_yearly=true
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
		-n|--dry-run)
			_dry_run=true
			;;
		-R|--force-reduction=*)
			case $mode in
			auto)
				error "not allow \"$mode\""
				;;
			esac
			mode=reduction
			option=$1
			case $option in
			-R)
				shift
				case $1 in
				-*)
					error "need value for $option"
					;;
				esac
				reduction_period=${1%%:*}
				case $reduction_period in
				week)
					reduction_day=${1#*:}
					;;
				month)
					reduction_month=${1#*:}
					;;
				year)
					reduction_year=${1#*:}
					;;
				esac
				;;
			--force-reduction=*)
				reduction_period=${1%%:*}
				reduction_period=${reduction_period#*=}
				case $reduction_period in
				week)
					reduction_day=${1#*:}
					;;
				month)
					reduction_month=${1#*:}
					;;
				year)
					reduction_year=${1#*:}
					;;
				esac
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
			options=$(echo "$1" | expand-options "ahn" "dRr")
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

	case $mode in
	auto)
		now_digittime=$(get-nowdigittime)
		putdebug 1 1 now_digittime
		if already-updating; then
			_latest_update=$(get-latestupdate)
			putdebug 1 3 _latest_update
			sct $src_path $dest_host:$dest_path/$now_digittime
			reduce-datastore
		else
			putdebug 1 4 _src_path dest_host dest_path
			sct -i $src_path $dest_host:$dest_path/$now_digittime
		fi
		;;
	reduction)
		putdebug 1 2 mode
		reduce-datastore
		;;
	today)
		putdebug 1 6 src_path dest_host dest_path
		if destpath-exist; then
			error "$dest_host:$dest_path already exist"
		else
			putdebug 1 8 src_path dest_host dest_path
			sct -i $src_path $dest_host:$dest_path
		fi
		;;
	esac

	finalize

	return 0
}

globalize()
{
	periodic_reduce_weekly=false
	periodic_reduce_monthly=false
	periodic_reduce_yearly=false
	mode=today
}

usage()
{
	case $1 in
	-s)
		cat <<- EOF
		Usage: $COMMAND_NAME [-nh] [-d <debug mode>] [--debug-commands=<debug commands>] [--debug-functions=<debug functions>] [-r dir] [--help] path host:path
		       $COMMAND_NAME -a [-nh] [-d <debug mode>] [--debug-commands=<debug commands>] [--debug-functions=<debug functions>] [-r dir] [--help] path host[:path]
		       $COMMAND_NAME -R key:day [-nh] [-d <debug mode>] [--debug-commands=<debug commands>] [--debug-functions=<debug functions>] [-r dir] [--help] path host[:path]
		EOF
		;;
	-l)
		cat <<- EOF
		OpenTools $PROGRAM_NAME $VERSION, a local directory tree to remote site backuper.

		Usage: $COMMAND_NAME [-nh] [-d <debug mode>] [--debug-commands=<debug commands>] [--debug-functions=<debug functions>] [-r dir] [--help] path host:path
		       $COMMAND_NAME -a [-nh] [-d <debug mode>] [--debug-commands=<debug commands>] [--debug-functions=<debug functions>] [-r dir] [--help] path host[:path]
		       $COMMAND_NAME -R key:day [-nh] [-d <debug mode>] [--debug-commands=<debug commands>] [--debug-functions=<debug functions>] [-r dir] [--help] path host[:path]

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
		  -r,  --backup-rootdir=dir    root directory on backup site. dir should be
		                               the absolute path name. all fies save under
		                               dir/host

		Auto backup mode:
		  -a,  --auto-backup           automatic backup by periodic daily, weekly,
		                               monthly and yearly.

		Reduction mode:
		  -R key:day,                  force reduce datastore with key at day.
		    --force-reduction=key:day  key={week,month,year} and day is a yyyymmdd form
		                               to which reduce all days before the day.
		EOF
		;;
	esac
	exit 0
}

initialize()
{
	local	__function__=initialize

	check-debug
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
		set-sshport $2
		if [ -z "$backup_rootdir" ]; then
			dest_path=$DESTDIR
		else
			dest_path=$backup_rootdir/$HOST
		fi
	fi
	dest_hostname=${dest_host#*@}
	_ssh_args="-p $_ssh_port $dest_host"
	backup_rootdir=$(echo $dest_path | sed -Ee 's|^(/[^/]+).*$|\1|')
	if connected $dest_hostname; then
		if ! rexec -f "test -d $backup_rootdir"; then
			error "$dest_host:$backup_rootdir not found"
		fi
	fi
	putdebug 1 1 dest_hostname mode
	case $mode in
	today|auto)
		day=$(date '+%d' | sed -Ee 's/^0?//')
		week=$(date '+%u')
		month=$(date '+%m' | sed -Ee 's/^0?//')
		year=$(date '+%Y')
		yday=$(date '+%j')
		stime_now=$(date '+%s')
		day_begining_month="$(date '+%Y%m')01"
		reduction_month=$(get-previousmonth $day_begining_month)
		reduction_year=$((year -= 1))
		;;
	reduction)
		putdebug 1 2 reduction_period
		case $reduction_period in
		week)
			stime_now=$(convdate-d2s $reduction_day)
			week=$(convdate-d2u $reduction_day)
			reduction_day=$(echo "$reduction_day" | awk '{print substr($0, 1, 8)}')
			day_begining_month=$(echo "$reduction_day" | awk '{print substr($0, 1, 6)"01"}')
			putdebug 1 3 stime_now day_begining_month
			;;
		month)
			reduction_month=$(echo "$reduction_month" | awk '{print substr($0, 1, 6)}')
			;;
		year)
			putdebug 1 4 reduction_year
			reduction_year=$(echo "$reduction_year" | awk '{print substr($0, 1, 4)}')
			;;
		esac
		;;
	esac
	if [ -z "$VERSION" ]; then
		warn "version not defined"
	fi
}

get-nowdigittime()
{
	convdate-h2n "$(env LANG=C TZ=Asia/Tokyo date)"
}

already-updating()
{
	local	__function__=already-updating

	putdebug 1 0 dest_host dest_path
	rexec -f "ls -d $dest_path/[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" > /dev/null 2>&1
}

get-latestupdate()
{
	local	__function__=get-latestupdate			\
		__latest_update

	__latest_update=$(rexec -f "cd $dest_path; ls -d [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9] | tail -1")
	putdebug 1 0 __latest_update
	convdate-n2h $__latest_update
}

reduce-datastore()
{
	local	__function__=reduce-datastore

	case $mode in
	auto)
		putdebug 1 1 periodic_reduce_monthly _day _day_start
		if $periodic_reduce_yearly && [ $yday -eq $_yday_start ]; then
			pushdown-datastore -y $dest_path
		elif $periodic_reduce_monthly && [ $day -eq $_day_start ]; then
			pushdown-datastore -m $dest_path
		elif $periodic_reduce_weekly && [ $week -eq $_week_start ]; then
			pushdown-datastore -w $dest_path
		fi
		;;
	reduction)
		putdebug 1 1 reduction_period reduction_day
		case $reduction_period in
		week)
			putdebug 1 2 dest_host dest_path
			pushdown-datastore -w $dest_path
			;;
		month)
			pushdown-datastore -m $dest_path
			;;
		year)
			pushdown-datastore -y $dest_path
			;;
		esac
		;;
	*)
		error "mode \"$mode\" not allowed"
		;;
	esac
}

destpath-exist()
{
	rexec -f "ls -d $dest_path" > /dev/null 2>&1
}

finalize()
{
	rmtmpfile -a
}

convdate-h2n()
{
	env LANG=C TZ=Asia/Tokyo date -j -f '%a %b %d %T %Z %Y' "$1" '+%Y%m%d%H%M'
}

convdate-d2s()
{
	env LANG=C TZ=Asia/Tokyo date -j -f '%Y%m%d' $1 '+%s'
}

convdate-d2u()
{
	env LANG=C TZ=Asia/Tokyo date -j -f '%Y%m%d' $1 '+%u'
}

convdate-n2h()
{
	env LANG=C TZ=Asia/Tokyo date -j -f '%Y%m%d%H%M' $1 '+%a %b %d %T %Z %Y'
}

convdate-s2d()
{
	env LANG=C TZ=Asia/Tokyo date -j -f '%s' $1 '+%Y%m%d'
}

convdate-s2m()
{
	env LANG=C TZ=Asia/Tokyo date -j -f '%s' $1 '+%m'
}

convdate-s2u()
{
	env LANG=C TZ=Asia/Tokyo date -j -f '%s' $1 '+%u'
}

convdate-s2ym()
{
	env LANG=C TZ=Asia/Tokyo date -j -f '%s' $1 '+%Y%m'
}

convdate-ym2s()
{
	env LANG=C TZ=Asia/Tokyo date -j -f '%Y%m' $1 '+%s'
}

get-nextmonth()
{
	echo $1 | awk '{
				year  = substr($0, 1, 4)
				month = substr($0, 5, 7)
				if (month < 12) {
					month++
				} else {
					year++
					month = 1
				}
				printf "%4d%02d", year, month
			}'
}

get-pastdigittimes()
{
	local	__day						\
		__day_begining					\
		__day_retrieved					\
		__days						\
		__digittimes					\
		__earliest=false				\
		__exclude=false					\
		__function__=get-pastdigittimes			\
		__last_update_week				\
		__mode						\
		__month						\
		__month_last					\
		__month_retrieved				\
		__path_retrieved				\
		__stime						\
		__stime_begining_month				\
		__stime_earliest				\
		__stime_end					\
		__week						\
		__year_retrieved

	while [ $# -gt 0 ] ; do
		case $1 in
		-e|--earliest)
			__earliest=true
			;;
		-m|--monthly)
			__mode=monthly
			;;
		-t|--tail-month-days)
			__mode=tail
			;;
		-w|--weekly)
			__mode=weekly
			;;
		-y|--yearly)
			__mode=yearly
			;;
		-x|--exclude)
			__exclude=true
			;;
		*)
			break
			;;
		esac
		shift
	done
	putdebug 1 1 __mode
	case $__mode in
	weekly)
		: $((__stime_earliest = stime_now - 6 * 24 * 60 * 60))
		putdebug 1 2 day_begining_month
		__stime_begining_month=$(convdate-d2s $day_begining_month)
		putdebug 1 3 __stime_earliest __stime_begining_month
		if [ $__stime_begining_month -gt $__stime_earliest ]; then
			__stime=$__stime_begining_month
			__day=$day_begining_month
		else
			__stime=$__stime_earliest
			__day=$(convdate-s2d $__stime_earliest)
		fi
		putdebug 1 4 __stime __day stime_now
		while [ $__stime -le $stime_now ]; do
			__day_retrieved=$(rexec -f "ls -d $dest_path/$__day* | head -1" 2> /dev/null)
			putdebug 1 5 __day_retrieved
			if [ -z "$__day_retrieved" ]; then
				warn "$dest_path/$__day* not found"
			else
				if $__exclude; then
					__exclude=false
				elif $__earliest; then
					__digittimes=$(basename $__day_retrieved)
					break
				else
					__digittimes="$__digittimes${__digittimes:+ }$(basename $__day_retrieved)"
				fi
			fi
			: $((__stime += 24 * 60 * 60))
			__day="$(convdate-s2d $__stime)"
			putdebug 1 6 __digittimes
			putdebug 1 7 __stime __day stime_now
		done
		;;
	monthly)
		__month_retrieved=$(rexec -f "ls -d $dest_path/$reduction_month*" 2> /dev/null)
		if [ -n "$__month_retrieved" ]; then
			for __path_retrieved in $__month_retrieved; do
				if $__exclude; then
					__exclude=false
				elif $__earliest; then
					__digittimes=$(basename $__path_retrieved)
					break
				else
					__digittimes="$__digittimes${__digittimes:+ }$(basename $__path_retrieved)"
				fi
			done
		else
			warn "nothing found in \"$dest_path/$reduction_month*\""
			return 0
		fi
		;;
	yearly)
		putdebug 1 8 dest_path reduction_year 
		__year_retrieved=$(rexec -f "ls -d $dest_path/$reduction_year*" 2> /dev/null)
		putdebug 1 9 __year_retrieved
		if [ -n "$__year_retrieved" ]; then
			for __path_retrieved in $__year_retrieved; do
				if $__exclude; then
					__exclude=false
				elif $__earliest; then
					__digittimes=$(basename $__path_retrieved)
					break
				else
					__digittimes="$__digittimes${__digittimes:+ }$(basename $__path_retrieved)"
				fi
			done
		else
			warn "nothing found in \"$dest_path/$reduction_year*\""
			return 0
		fi
		;;
	esac
	echo "$__digittimes"
}

get-previousmonth()
{
	echo $1 | awk '{
				year  = substr($0, 1, 4)
				month = substr($0, 5, 7)
				if (month > 1) {
					month--
				} else {
					year--
					month = 12
				}
				printf "%4d%02d", year, month
			}'
}

pushdown-datastore()
{
	local	__get_pastdigittimes_args			\
		__dest_path					\
		__dest_path_early				\
		__digittime					\
		__function__=pushdown-datastore			\
		__src_path

	while [ $# -gt 0 ] ; do
		case $1 in
		-m|--monthly)
			__get_pastdigittimes_args='-m'
			;;
		-w|--weekly)
			__get_pastdigittimes_args='-w'
			;;
		-y|--yearly)
			__get_pastdigittimes_args='-y'
			;;
		*)
			break
			;;
		esac
		shift
	done
	__dest_path=$1
	__dest_path_early=$__dest_path/$(get-pastdigittimes -e $__get_pastdigittimes_args)
	putdebug 1 0 __dest_path __dest_path_early __get_pastdigittimes_args
	for __digittime in $(get-pastdigittimes -x $__get_pastdigittimes_args); do
		__src_path=$__dest_path/$__digittime
		if rct $__src_path $__dest_path_early; then
			srm $__src_path
		else
			error "reduce from $__src_path -> $__dest_path_early filed"
		fi
	done
	smv $__dest_path_early $__src_path
}

rct()
{
			rexec "tar -cf - -C $1 . | tar -vxpf - -C $2"
}

smv()
{
	local	__dest_path=$2					\
		__destfstype					\
		__function__=smv				\
		__src_path=$1					\
		__zfsrootfs

	__destfstype=$(get-fstype $dest_host:$backup_rootdir)
	case $__destfstype in
	zfs)
	    __zfsrootfs=$(get-zfsfs -r $dest_host:$backup_rootdir)
		rexec "zfs rename $__zfsrootfs$__src_path $__zfsrootfs$__dest_path"
		;;
	ufs)
		rexec "mv $__src_path $__dest_path"
		;;
	*)
		error "irregular filesystem type:$__destfstype"
		;;
	esac
}

srm()
{
	local	__dest_path=$1					\
		__destfstype					\
		__function__=srm				\
		__zfsrootfs

	__destfstype=$(get-fstype $dest_host:$backup_rootdir)
	case $__destfstype in
	zfs)
	    __zfsrootfs=$(get-zfsfs -r $dest_host:$backup_rootdir)
		rexec "zfs destroy $__zfsrootfs$__dest_path"
		;;
	ufs)
		rexec "rm -rf $__dest_path"
		;;
	*)
		error "irregular filesystem type:$__destfstype"
		;;
	esac
}

main "$@" || exit 1
