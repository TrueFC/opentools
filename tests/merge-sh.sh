#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../include/common.inc
. ../lib/subc
. ../lib/sysrc

_debug=false
_debug_level=5
file=../tmp/foo

rm -f ../tmp/*

echo "- include (foo2, foo5) -"
cat <<EOF > ${file}_1
# - include (foo2, foo5) -
foo1="This is foo1"
foo2="This is foo2"
foo3="This is foo3"
foo4="This is foo4"
foo5="This is foo5"
EOF
bar='foo2="This is bar1"
foo5="This is bar2"'
putdebug 1 merge-sh.sh file bar
merge-sh ${file}_1 bar

echo "- not include (bar1, bar2) -"
cat <<EOF > ${file}_2
# - not include (bar1, bar2) -
foo1="This is foo1"
foo2="This is foo2"
foo3="This is foo3"
foo4="This is foo4"
foo5="This is foo5"
EOF
bar='bar1="This is bar1"
bar2="This is bar2"'
putdebug 1 merge-sh.sh file bar
merge-sh ${file}_2 bar

echo "- partially include (foo2, bar2, foo4) -"
cat <<EOF > ${file}_3
# - partially include (foo2, bar2, foo4) -
foo1="This is foo1"
foo2="This is foo2"
foo3="This is foo3"
foo4="This is foo4"
foo5="This is foo5"
EOF
bar='foo2="This is bar1"
bar2="This is bar2"
foo4="This is bar3"'
putdebug 1 merge-sh.sh file bar
merge-sh ${file}_3 bar

echo "- coiside values (foo2, foo4) -"
cat <<EOF > ${file}_4
# - coiside values (foo2, foo4) -
foo1="This is foo1"
foo2="This is foo2"
foo3="This is foo3"
foo4="This is foo4"
foo5="This is foo5"
EOF
bar='foo2="This is foo2"
foo4="This is foo4"'
putdebug 1 merge-sh.sh file bar
merge-sh ${file}_4 bar

echo "- include comments (foo2, bar2, foo4) -"
cat <<EOF > ${file}_5
# - include comments (foo2, bar2, foo4) -
foo1="This is foo1" # Comments for foo1

foo2="This is foo2" # Comments for foo2
# Comments for foo3
foo3="This is foo3"
foo4="This is foo4" # Comments for foo4
foo5="This is foo5"
EOF
bar='foo2="This is bar1"
bar2="This is bar2" # Comments for bar2
foo4="This is bar3"'
putdebug 1 merge-sh.sh file bar
merge-sh ${file}_5 bar

echo "- include continuation line (foo1, bar2, foo5, foo3) -"
cat <<EOF > ${file}_6
# - include continuation line (foo1, bar2, foo5, foo3) -
foo1="This is foo1"
foo2="This is foo2 \\
  with contiuation line 1 \\
and contiuation line 2"
foo3="This is foo3 \\
with contiuation line 1"
foo4="This is foo4 \\
	with contiuation line 1"
foo5="This is \\
foo5"
EOF
bar='foo1="This is bar1"
bar2="This is bar2"
foo5="This is foo5"
foo3="This is bar3"'
putdebug 1 merge-sh.sh file bar
merge-sh ${file}_6 bar

echo "- include commented continuation line (foo1, bar2, foo5, foo3) -"
cat <<EOF > ${file}_7
# - include commented continuation line (foo1, bar2, foo5, foo3) -
#foo1="This is foo1"
#foo2="This is foo2 \\
#  with contiuation line 1 \\
#and contiuation line 2"
foo3="This is foo3 \\
with contiuation line 1"
#foo4="This is foo4 \\
#	with contiuation line 1"
foo5="This is \\
foo5"
EOF
bar='foo1="This is bar1"
bar2="This is bar2"
foo5="This is foo5"
foo3="This is bar3"'
putdebug 1 merge-sh.sh file bar
merge-sh ${file}_7 bar

echo "- include commented continuation line of same item with commentout mode (foo1, bar2, foo5, foo3) -"
cat <<EOF > ${file}_8
# - include commented continuation line of same item with commentout mode (foo1, bar2, foo5, foo3) -
#foo1="This is foo1"
#foo2="This is foo2 \\
#  with contiuation line 1 \\
#and contiuation line 2"
#foo3="This is foo3 \\
#with contiuation line 1"
foo1="This is foo1 \\
  with contiuation line 1 \\
and contiuation line 2"
foo4="This is foo4 \\
	with contiuation line 1"
foo5="This is \\
foo5"
EOF
bar='foo1="This is bar1"
bar2="This is bar2"
foo5="This is foo5"
foo3="This is bar3"'
putdebug 1 merge-sh.sh file bar
merge-sh -c ${file}_8 bar
