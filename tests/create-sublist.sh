#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../lib/subc

_debug=false
_debug_level=1

inheritances="_debug _dry_run _ignore_error _runc_args _verbose_output _os_update _ports_update OPENTOOLSDIR=/.dake BDSDIR=/.dake DAKEDIR=/.dake DISTSDIR=/.dake/dists"
: ${_os_update:=false}
: ${_ports_update:=true}
: ${_debug:=true}
: ${_dry_run:=true}
: ${_ignore_error:=false}
: ${_runc_args:="-v -f"}
: ${_verbose_output:=true}

create-sublist "${inheritances}"
