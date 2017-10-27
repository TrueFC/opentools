#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4
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
. ${OPENTOOLSINCDIR}/plugins.inc

main() {
	local	__options

	while [ $# -gt 0 ] ; do
		case $1 in
		-d|--debug-level*)
			_debug=true
			case $1 in
			-d)
				shift
				_debug_level=$1
				;;
			--debug-level=*)
				_debug_level=${1#*=}
				;;
			--debug-level)
				shift
				_debug_level=$1
				;;
			esac
			if ! echo ${_debug_level} | egrep -q '[[:digit:]]+'; then
				error main "debug level should be a number"
			fi
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
		-p|--protocol*)
			case $1 in
			-p)
				shift
				_protocol=$1
				;;
			--protocol=*)
				_protocol=${1#*=}
				;;
			--protocol)
				shift
				_protocol=$1
				;;
			esac
			;;
		-u|--user*)
			case $1 in
			-u)
				shift
				_user=$1
				;;
			--user=*)
				_user=${1#*=}
				;;
			--user)
				shift
				_user=$1
				;;
			esac
			;;
		-v|--verbose-output)
			_verbose_output=true
			;;
		-[a-zA-Z]*)
			options=`echo $1 | sed -Ee 's|^-([[:alpha:]]+).*$|\1|'`
			value=`echo $1 | sed -Ee 's|^-[[:alpha:]]+(.*)$|\1|'`
			illegal_option=`echo ${options} | tr -d "[adhnr]" | sed -Ee 's|^(.).*$|\1|'`
			if [ -n "${illegal_option}" ]; then
				error main "illegal option \`-${illegal_option}'"
			fi
			options=`echo ${options} | sed -Ee 's|(.)|-\1 |g' -e 's| *$||'`
			shift
			set -- ${options} ${value} $*
			continue
			;;
		*)
			break
			;;
		esac
		shift
	done
    while getopts 'a A: F: R f n d: i h' opt; do
	case ${opt} in
	    a)
                update_allplugins=1
		;;
	    A)
                case ${OPTARG} in
		    8)
		        acroread_version=8
			update_acroread=1
			;;
		    9)
		        acroread_version=9
			update_acroread=1
			;;
		    *)
		        error "Acroread version \"${OPTARG}\" not sopported"
			;;
		esac
		;;
	    F)
	        case ${OPTARG} in
		    9)
		        flash_version=9
			update_flash=1
			;;
		    10)
		        flash_version=10
			update_flash=1
			;;
		    11)
		        flash_version=11
			update_flash=1
			;;
		    *)
		        error "Macromedia Flash version \"${OPTARG}\" not sopported"
			;;
		esac
		;;
	    R)
	        update_realplayer=1
		;;
	    f)
	        force_to_install=1
		;;
	    n)
	        ECHO="echo "
		_do_not_execute_but_trace=yes
		;;
	    d)
	        _debug=${OPTARG}
		;;
	    i)
	        _ignore_error=1
		;;
	    h)
	        usage;
		;;
	    *)
	        ;;
	esac
    done
    shift `expr ${OPTIND} - 1`

    initialize

    if test ${update_acroread}; then
	eval acroread_plugin=${ACROREAD_JPN_PLUGIN}
    fi
    putdebug 1 main plugins update_acroread update_flash update_realplayer
    if test ${update_flash}; then
	case ${flash_version} in
	    [79])
	        linux_flashplugin_dir='linux-flashplugin'
		eval flash_plugin=${FLASH_PLUGIN}
		;;
	    1[01])
	        linux_flashplugin_dir='linux-f10-flashplugin'
		eval flash_plugin=${FLASH_PLUGIN}
		;;
	esac
    fi
    putdebug 1 main flash_plugin
    if test ${update_realplayer}; then
		realplayer_plugin="`echo ${REALPLAYER_PLUGIN}`"
    fi
    putdebug 1 main realplayer_plugin
    putdebug 5 main plugins
    for plugin in ${plugins}; do
	eval global_plugins='${'${plugin}'_plugin}'
	expand_csh_glob ${global_plugins}
	global_plugins=`eval echo ${global_plugins}`
	putdebug 5 main global_plugins
	first_global_plugin=`echo ${global_plugins} | cut -f 1 -d " "`
	first_local_plugin=${LOCAL_PLUGINDIR}/npwrapper.`basename ${first_global_plugin}`
	putdebug 2 main global_plugins
	putdebug 3 main force_to_install plugin global_plugins first_global_plugin first_local_plugin
	if [ -n "${force_to_install}" ]; then
	    for global_plugin in ${global_plugins}; do
		local_plugin=${LOCAL_PLUGINDIR}/npwrapper.`basename ${global_plugin}`
		putdebug 5 main local_plugin
		if [ -f ${local_plugin} ]; then
		    ${ECHO}nspluginwrapper -r ${local_plugin}
		fi
		${ECHO}nspluginwrapper -i ${global_plugin}
	    done
	else	    
	    if [ ! -f ${first_local_plugin} -o ${first_global_plugin} -nt ${first_local_plugin} ]; then
		for global_plugin in ${global_plugins}; do
		    local_plugin=${LOCAL_PLUGINDIR}/npwrapper.`basename ${global_plugin}`
		    if [ -f ${local_plugin} ]; then
			${ECHO}nspluginwrapper -r ${local_plugin}
		    fi
		    ${ECHO}nspluginwrapper -i ${global_plugin}
		done
	    fi		
	fi
    done

    finalize

    return 0
}

initialize()
{
    local diskless_valid run_diskless
    diskless_valid=`/sbin/sysctl -n vfs.nfs.diskless_valid 2> /dev/null`
    if [ ${diskless_valid} -gt 0 ]; then
	run_diskless=1
    fi
    if test ${update_acroread} || test ${update_allplugins}; then
	update_acroread=1
	test ${acroread_version} || acroread_version=8
	if test ${run_diskless}; then
	    if [ -z "`chk_installed_pkg acroread ${acroread_version}`" ]; then
		error "acroread${acroread_version} not installed"
	    fi
	else
	    if [ -z "`get_installed_ports japanese/acroread${acroread_version}`" ]; then
		error "japanese/acroread${acroread_version} not installed"
	    fi
	fi
	plugins="acroread ${plugins}"
    fi
    if test ${update_flash} || test ${update_allplugins}; then
	update_flash=1
	test ${flash_version} || flash_version=11
	if test ${run_diskless}; then
	    if [ -z "`chk_installed_pkg flashplugin ${flash_version}`" ]; then
		error "flashplugin${flash_version} not installed"
	    fi
	else
	    case ${flash_version} in
	        9)
	            if [ -z "`get_installed_ports www/linux-flashplugin9`" ]; then 
			error "www/linux-flashplugin9 not installed"
		    fi
		    ;;
	        10)
	            ports="www/linux-f10-flashplugin10 ${ports}"
		    if [ -z "`get_installed_ports www/linux-f10-flashplugin10`" ]; then 
			error "www/linux-f10-flashplugin10 not installed"
		    fi
		    ;;
	        11)
	            ports="www/linux-f10-flashplugin11 ${ports}"
		    if [ -z "`get_installed_ports www/linux-f10-flashplugin11`" ]; then 
			error "www/linux-f10-flashplugin11 not installed"
		    fi
		    ;;
	    esac
	fi
        plugins="flash ${plugins}"
    fi
    if test ${update_realplayer} || test ${update_allplugins}; then
	update_realplayer=1
	if test ${run_diskless}; then
	    if [ -z "`chk_installed_pkg mplayer-plugin 3.55`" ]; then
		error "mplayer-plugin 3.55 not installed"
	    fi
	else
	    if [ -z "`get_installed_ports www/linux-mplayer-plugin`" ]; then 
		error "www/linux-mplayer-plugin not installed"
	    fi
	fi
	plugins="realplayer ${plugins}"
    fi
}

chk_installed_pkg()
{
    local application_name=$1 version=$2

    case ${application_name} in
	acroread)
            if [ -x /usr/local/bin/acroread${version} ]; then
		echo 'true'
	    else
		echo ''
	    fi
	    ;;
        flashplugin)
            if [ -f /compat/linux/usr/lib/libflashsupport.so ]; then
		echo 'true'
	    else
		echo ''
	    fi
	    ;;
        mplayer-plugin)
            if [ -f /usr/local/lib/npapi/linux-mplayerplug-in/mplayerplug-in.so ]; then
		echo 'true'
	    else
		echo ''
	    fi
	    ;;
    esac
}

finalize()
{
    test ${_debug} || rm -f ${tmp_filename}
}

usage ()
{
    cat <<EOF
${cmd_name} [options]
 	-a		all plugins
	-A version	acroread version
	-F version	flash version
	-R		real player plugin
	-f		force to install
	-d devel	debug with command trace
	-i		ignore errors (for debug)
	-h		show this message
EOF
    exit 0
}

main $@ || exit 1



