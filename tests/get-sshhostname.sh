#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../include/common.inc
. ../lib/subc

_debug=true
_debug_level=1

putdebug 1 get-sshhostname.sh _ssh_config
#cat  ${_ssh_config} |awk '{print $0}'
get-sshhostname ob
