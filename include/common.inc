#!/bin/sh
#-*- mode: sh; tab-width: 8; mode:sh -*-
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

COMMAND_NAME=$(basename $0 .sh)
PROGRAM_NAME=$(echo "$COMMAND_NAME" | awk '{print toupper(substr($0, 1, 1))substr($0, 2, length($0))}')

if [ -f /etc/opentools.conf ]; then
. /etc/opentools.conf
elif [ -f /usr/local/etc/opentools.conf ]; then
. /usr/local/etc/opentools.conf
fi
: ${OPENTOOLSINCDIR:=$OPENTOOLSDIR/include}
: ${OPENTOOLSBINDIR:=$OPENTOOLSDIR/bin}
: ${OPENTOOLSLIBDIR:=$OPENTOOLSDIR/lib}
: ${OPENTOOLSDATADIR:=$OPENTOOLSDIR/data}
: ${OPENTOOLSTMPLDIR:=$OPENTOOLSDIR/Templates}
: ${BDSDIR:=$OPENTOOLSDIR/../bds}
: ${BDSINCDIR:=$BDSDIR/include}
CURDIR=$(pwd)
: ${LOCALBASE:=/usr/local}
: ${MNTDIR:=/mnt}
: ${TEMPDIR:=/var/tmp}
: ${DEBUG_COMMANDS:=$COMMAND_NAME};				export DEBUG_COMMANDS
: ${DEBUG_FUNCTIONS:="main initialize finalize"};		export DEBUG_FUNCTIONS

: ${_mntdir:=""}
: ${_mntdirs:=""}
: ${_dry_run:=false};						export _dry_run
: ${_verbose_output:=false};					export _verbose_output
: ${_force_execute:=false};					export _force_execute
: ${_debug:=false};						export _debug
: ${_debug_mode:=level};					export _debug_mode
: ${_debug_level:=0};						export _debug_level
: ${_debug_commands:="$DEBUG_COMMANDS"};			export _debug_commands
: ${_debug_functions:="$DEBUG_FUNCTIONS"};			export _debug_functions
: ${_ignore_error:=false}
: ${_prefix_tmpfile:="tmpfile"}
: ${_tmpfilename:="tmpfile"}
: ${_tmpfiles:=""}
: ${_is_remote_checked:=false}
: ${_is_remote:=false}
: ${_ssh_args:="-o StrictHostKeyChecking=no"}
: ${_ssh_config:="$HOME/.ssh/config"}
: ${_ssh_host:=""}
: ${_ssh_user:=""}
: ${_ssh_port:="22"};						export _ssh_port
: ${_logging_now=false}
