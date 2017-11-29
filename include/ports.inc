#!/bin/sh
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

VERSION_CREATE_PORTSTREE=1.0
VERSION_GET_XEPKGDATA=1.0
VERSION_CLONE_XEPKGS_XEPKGDATA=1.0
eval VERSION=\${VERSION_$(echo $PROGRAM_NAME | tr '-' '_' | tr "[[:lower:]]" "[[:upper:]]")}

: ${PORTSDIR:=/usr/ports};					export PORTSDIR
: ${INDEXDIR:=/usr/ports}
: ${PORTSREPO:=/usr/ports}
: ${PORTS_NONCATEGORIES:='.*,CHANGES,CONTRIBUTING.md,COPYRIGHT,GIDs,Keywords,LEGAL,MOVED,Makefile,Mk,README,Templates,Tools,UIDs,UPDATING'}; \
								export PORTS_NONCATEGORIES
: ${WRKDIRPREFIX:="/var/ports"}
: ${PACKAGES:="/var/ports/packages"}
: ${DISTDIR:="/var/ports/distfiles"}
: ${PKGCONF:="/etc/pkg/FreeBSD.conf"}
: ${PKGTOOLSCONF:="$LOCALBASE/etc/pkgtools.conf"}
: ${PKGSUFX:=".txz"}
: ${BATCH:="yes"}
: ${DEFAULT_VERSIONS:="perl5=5.26 ruby=2.4"}
: ${COMPILER_TYPE:="clang"}
: ${USE_PACKAGE_DEPENDS:="yes"}
: ${DISABLE_VULNERABILITIES:="yes"}
: ${OVERRIDE_LINUX_NONBASE_PORTS:="c6"}

: ${_force_create:=false}
: ${_metaport_only:=false}
: ${_option_metaport:=false}
: ${_ports_only:=false}
: ${_templatedir:=$OPENTOOLSTMPLDIR}
: ${_portbuild_mode:=pkginstall}
: ${_portbuild_make_args:=""}
: ${_portbuild_make_target:=install}
: ${_prune_userland:=false}
: ${_root_port:=false}
