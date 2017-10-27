#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../lib/subc

_f_test_awk='
BEGIN {
}
{
	a = split($0, line, /\\n/)
}
END {
	print a[3]
}'

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
awk "$_f_test_awk" $file
#awk -F $'\n' "$_f_test_awk" $file
