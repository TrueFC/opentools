#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../lib/subc
. ../lib/portsc

_debug=false
_debug_level=1

args="A,B,C"
echo "- args='$args' -"
get-portargs "$args"

args="A,B='this is B',C"
echo "- args='$args' -"
get-portargs "$args"

B='this is B'
args='A,B="$B",C'
echo "- args='$args' -"
get-portargs "$args"
