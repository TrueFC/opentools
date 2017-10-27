#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../lib/subc

_special_shell_functions="copy backup"
_debug=true
_debug_level=1

echo "- command:'cp' -"
which-command cp

echo "- command:'echo' -"
which-command echo

echo "- command:'copy'-"
which-command copy

echo "- command:'runc' -"
which-command runc

