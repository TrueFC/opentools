#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../lib/subc

_debug=false
_debug_level=1

rm -f ../tmp/foo
message="This is echo redirect."
file="../tmp/foo"
commandline='echo "$message" > $file'
echo "- echo \"$message\" > $file -"
evar echo "\$message" \> \$file
evar $commandline
#runc $(evar $commandline)
