#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. $OPENTOOLSDIR/include/common.inc
. $OPENTOOLSLIBDIR/subc
. $OPENTOOLSLIBDIR/sysrc
_debug=true
_debug_mode=module
_debug=false
_debug_level=1
_debug_commands="merge-config"
_debug_functions="merge-config"
_dry_run=true
_dry_run=false

file=../tmp/foo

rm -f ../tmp/foo*

echo "- include (foo2, foo5) -"
#_debug=true
cat <<EOF > ${file}_1
# - include (foo2, foo5) -
foo1 = val11
foo2 = val21
foo3 = val31
foo4 = val41
foo5 = val51
EOF
bar='foo2 = val01
foo5 = val01'
putdebug 1 merge-config.sh file bar
merge-config ${file}_1 bar
_debug=false

echo "- not include (bar1 bar2) -"
cat <<EOF > ${file}_2
# - not include (bar1 bar2) -
foo1 = val11
foo2 = val21
foo3 = val31
foo4 = val41
foo5 = val51
EOF
bar='bar1 = val01
bar2 = val01'
putdebug 1 merge-config.sh file bar
merge-config ${file}_2 bar

echo "- partially include (foo2, foo4) -"
cat <<EOF > ${file}_3
# - partially include (foo2, foo4) -
foo1 = val11
foo2 = val21
foo3 = val31
foo4 = val41
foo5 = val51
EOF
bar='foo2 = val01
bar2 = val01
foo4 = val01'
putdebug 1 merge-config.sh file bar
merge-config ${file}_3 bar

#_debug=true
echo "- coiside values (foo2, foo4) -"
cat <<EOF > ${file}_4
# - coiside values (foo2, foo4) -
foo1 = val11
foo2 = val21
foo3 = val31
foo4 = val41
foo5 = val51
EOF
bar='foo2 = val21
foo4 = val41'
putdebug 1 merge-config.sh file bar
merge-config ${file}_4 bar

_debug=false
echo "- include comments (foo2, foo3, bar2) -"
cat <<EOF > ${file}_5
# - include comments (foo2, foo3, bar2) -
foo1 = val11
foo2 = val21	# Comments for foo2

# Comments for foo3
foo3 = val31
foo4 = val41	# Comments for foo4

foo5 = val51
EOF
bar='foo2 = val01
bar2 = val01	# Comments for bar2
foo3 = val01'
putdebug 1 merge-config.sh file bar
merge-config ${file}_5 bar

echo "- include commented line (foo1, foo2, foo3, foo5) -"
cat <<EOF > ${file}_6
# - include commented line (foo1, foo2, foo3, foo5) -
foo1 = val11
#foo2 = val21
#foo3 = val31
#foo4 = val41
foo5 = val51
EOF
bar='foo1 = val01
bar2 = val01
foo5 = val01
foo2 = val01
foo3 = val01'
putdebug 1 merge-config.sh file bar
merge-config ${file}_6 bar

echo "- include same keys (foo1, foo2, foo3, foo5) -"
cat <<EOF > ${file}_7
# - include same keys (foo1, foo2, foo3, foo5) -
foo1 = val11
#foo2 = val21
#foo3 = val31
#foo1 = val31
#foo4 = val41
foo5 = val51
EOF
bar='foo1 = val01
bar2 = val01
foo5 = val01
foo2 = val01
foo3 = val01'
putdebug 1 merge-config.sh file bar
merge-config ${file}_7 bar

echo "- include commented line with commentout mode (foo1, foo2, foo3, foo5) -"
cat <<EOF > ${file}_8
# - include commented line with commentout mode (foo1, foo2, foo3, foo5) -
foo1 = val11
#foo2 = val21
#foo3 = val31
#foo4 = val41
foo5 = val51
EOF
bar='foo1 = val01
bar2 = val01
foo5 = val01
foo2 = val01
foo3 = val01'
putdebug 1 merge-config.sh file bar
merge-config -c ${file}_8 bar

echo "- include same keys with commentout mode (foo1, foo2, foo3, foo5) -"
cat <<EOF > ${file}_9
# - include same keys with commentout mode (foo1, foo2, foo3, foo5) -
foo1 = val11
#foo2 = val21
#foo3 = val31
#foo1 = val31
#foo4 = val41
foo5 = val51
EOF
bar='foo1 = val01
bar2 = val01
foo5 = val01
foo2 = val01
foo3 = val01'
putdebug 1 merge-config.sh file bar
merge-config -c ${file}_9 bar

echo "- include same keys after with commentout mode (foo1, foo2, foo3, foo5) -"
cat <<EOF > ${file}_10
# - include same keys after with commentout mode (foo1, foo2, foo3, foo5) -
#foo1 = val11
#foo2 = val21
#foo3 = val31
foo1 = val31
#foo4 = val41
foo5 = val51
EOF
bar='foo1 = val01
bar2 = val01
foo5 = val01
foo2 = val01
foo3 = val01'
putdebug 1 merge-config.sh file bar
merge-config -c ${file}_10 bar
