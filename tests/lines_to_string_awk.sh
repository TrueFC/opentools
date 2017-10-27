#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../lib/subc

_debug=false
_debug_level=1
file=../tmp/foo

echo "- include all -"
cat <<EOF > $file
foo:Line 1
foo:Line 2
bar:Line 1
bar:Line 2
foo:Line 3
EOF
bar='bar:Line 1
bar:Line 2'
putdebug 1 isinclude-lines.sh bar
awk "$_f_lines_to_newlined_string_awk" $file
