#-*- mode: sh; tab-width: 8; -*-
# ex:ts=8
#
# Copyright (c) 2009 Kazuhiko Kiriyama <kiri@OpenEdu.org>
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

VERSION_NEWEST=1.0
VERSION_SCT=1.0
eval VERSION=\${VERSION_$(echo $PROGRAM_NAME | tr '-' '_' | tr "[[:lower:]]" "[[:upper:]]")}
	
: ${SRCDIR:=/usr/src}
: ${SRCOBJ:=/usr/obj}
: ${SVN_DEFAULT_HOST:=svn.freebsd.org}
: ${SVN_ROOT_URL:=svn://$SVN_DEFAULT_HOST}
: ${KERNCONF:=GENERIC}
: ${IGNOREDIRS:="/boot/kernel.old /usr/packages /usr/distfiles /usr/home /usr/ports /usr/obj /usr/src /usr/portbuild"}

: ${_mmrootdir:=/var/tmp/mergemaster}
: ${_exclude_mmfiles:="make.conf resolv.conf /etc/rc.conf fstab"}
: ${_restore_files:="/etc/master.passwd /etc/group /etc/ssh/sshd_config"}
