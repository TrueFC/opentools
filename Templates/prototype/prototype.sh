#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4
#
# Copyright (c) YYYY Foo Bar <foo@OpenEdu.org>
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
# $OpenTools$
#
#comment: Prototype sh script with opentools subc method
#commandline: prototye.sh
#use:
#cvs: :pserver:anoncvs@cvs.openedu.org:/home/tcvs prototype.sh
#maintainer: foo@OpenEdu.org
#includes:
#depends:
#description:
#examples: 
#

. /usr/opentools/subc
#. /home/kiri/projects/opentools/subc

main()
{
	while getopts 'p m i u n d: h' opt; do
		case ${opt} in
		p)
			update_ports_tree=yes
			;;
		m)
			merge_ports_tree=yes
			;;
		i)
			rebuild_index=yes
			;;
		u)
			portupgrade=yes
			;;
		n)
			ECHO="echo "
			dry_run=yes
			;;
		d)
			_debug=true
			_debug_level=${OPTARG}
			;;
		h)
			usage;
			;;
		*)
			;;
		esac
	done
	shift $((${OPTIND} - 1))

	initialize

	if test ${update_ports_tree}; then
		${ECHO}/usr/reconfig/reconfig.sh s p
	fi
	if test ${merge_ports_tree}; then
		for port_openedu in ${PORTS_OPENEDU}; do
			${ECHO}rm -rf /usr/ports/${port_openedu}
		done
		${ECHO}cd /usr/ports; ${ECHO}cvs -d ${PCVSROOT} co -P ${PORTS_OPENEDU}
	fi
	if test ${rebuild_index}; then
		${ECHO}cd /usr/ports; ${ECHO}make index
	fi
	if test ${portupgrade}; then
		pre_portupgrade
		${ECHO}mkdir -p /var/log/portupgrade
		${ECHO}portupgrade -arvRL /var/log/portupgrade/%s::%s.log
		post_portupgrade
	fi

	finalize

	return 0
}

initialize()
{
}

finalize()
{
	test ${debug} || rm -f ${tmp_filename}
}

usage ()
{
	cat <<- EOF
	${cmd_name} [options]
	    -p  update ports tree to -current by cvsup
	    -m  merge openedu ports to ports tree
	    -i  rebuild ports INDEX
	    -u  portupgrade up and down ward recursively
	    -n  do not execute but trace
	    -d  debug mode
	    -h  show this message
	EOF
	exit 0
}

main $@ || exit 1
