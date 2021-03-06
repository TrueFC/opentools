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

VERSION_BWR=1.0
VERSION_SBACKUP=1.0
VERSION_SLGN=1.0
VERSION_W3=1.0
VERSION_WL=1.0
VERSION_EMCS=1.0
VERSION_XTRM=1.0
eval VERSION=\${VERSION_$(echo $PROGRAM_NAME | tr '-' '_' | tr "[[:lower:]]" "[[:upper:]]")}
	
: ${BACKUPROOTDIR:=/hosts}
: ${EMACS_CMD:=xemacs}
EMACS_NAME=$(echo "$EMACS_CMD" | awk '{n=index($0,"emacs");print toupper(substr($0, 1, n))substr($0, n+1, length($0))}')
: ${EMACS_TTY_ARGS:='-nw -no-site-file'}
: ${EMACS_BACKGROUND_PIXMAP:=$OPENTOOLSDATADIR/images/Firebird-Kingdom.xpm}
: ${EMACS_FOREGROUND_COLOR:=Black}
: ${EMACS_BACKGROUND_COLOR:=White}
: ${EMACS_BACKGROUND_DEFAULT:=${EMACS_BACKGROUND_COLOR}}
: ${WL_EMACS_ARGS:='-f prom-wl'}
: ${WL_EMACS_BACKGROUND_COLOR:=Black}
: ${WL_EMACS_BACKGROUND_DEFAULT:=${WL_EMACS_BACKGROUND_PIXMAP}}
: ${WL_EMACS_BACKGROUND_PIXMAP:=$OPENTOOLSDATADIR/images/Firebird-Kingdom.xpm}
: ${WL_EMACS_FILL_COLUMN:=60}
: ${WL_EMACS_FOREGROUND_COLOR:=White}
: ${WL_EMACS_PRE_RUN_COMMANDS:=mailprc}
: ${WL_EMACS_TTY_ARGS:='-nw -no-site-file -f wl'}
: ${XTERM_FOREGROUND_COLOR:=Black}
: ${XTERM_BACKGROUND_COLOR:=White}

: ${_backuphostport:=22}
: ${_exclude_patterns:=${EXCLUDE_PATTERNS:='/{current,tmp,dev,compat,var/{tmp,mail},home/*/{.opera/cache,.cache}}'}}
: ${_month_start:=${MONTH_START:=1}}
: ${_week_start:=${WEEK_START:=1}}
: ${_day_start:=${DAY_START:=1}}
: ${_yday_start:=${YDAY_START:=1}}
