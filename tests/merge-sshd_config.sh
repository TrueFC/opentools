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
foo1 val1
foo2 val2
foo3 val3
foo4 val4
foo5 val5
EOF
bar='foo2 val02
foo5 val05'
putdebug 1 merge-sshd_config.sh file bar
merge-sshd_config ${file}_1 bar

echo "- not include (bar1, bar2) -"
cat <<EOF > ${file}_2
# - not include (bar1, bar2) -
foo1 val1
foo2 val2
foo3 val3
foo4 val4
foo5 val5
EOF
bar='bar1 val01
bar2 val02'
putdebug 1 merge-sshd_config.sh file bar
merge-sshd_config ${file}_2 bar

echo "- partially include (foo2, bar2, foo4) -"
cat <<EOF > ${file}_3
# - partially include (foo2, bar2, foo4) -
foo1 val1
foo2 val2
foo3 val3
foo4 val4
foo5 val5
EOF
bar='foo2 val02
bar2 val02
foo4 val04'
putdebug 1 merge-sshd_config.sh file bar
merge-sshd_config ${file}_3 bar

echo "- coiside values (foo2, foo4) -"
cat <<EOF > ${file}_4
# - coiside values (foo2, foo4) -
foo1 val1
foo2 val2
foo3 val3
foo4 val4
foo5 val5
EOF
bar='foo2 val2
foo4 val4'
putdebug 1 merge-sshd_config.sh file bar
merge-sshd_config ${file}_4 bar

echo "- include comments (foo2, bar2, foo4) -"
cat <<EOF > ${file}_5
# - include comments (foo2, bar2, foo4) -
foo1 val1 # Comments for foo1
foo2 val2 # Comments for foo2

# Comments for foo3
foo3 val3
foo4 val4 # Comments for foo4
foo5 val5
EOF
bar='foo2 val02
bar2 val02 # Comments for bar2
foo4 val04'
putdebug 1 merge-sshd_config.sh file bar
merge-sshd_config ${file}_5 bar

echo "- include commented line (foo1, bar2, foo5, foo2, foo3) -"
cat <<EOF > ${file}_6
# - include commented line (foo1, bar2, foo5, foo2, foo3) -
foo1 val1
#foo2 val2
#foo3 val3
#foo4 val4
foo5 val5
EOF
bar='foo1 val01
bar2 val02
foo5 val05
foo2 val2
foo3 val03'
putdebug 1 merge-sshd_config.sh file bar
merge-sshd_config ${file}_6 bar

echo "- include same keys (foo1, bar2, foo5, foo2, foo3) -"
cat <<EOF > ${file}_7
# - include same keys (foo1, bar2, foo5, foo2, foo3) -
foo1 val1
#foo2 val2
#foo3 val3
#foo1 val3
#foo4 val4
foo5 val5
EOF
bar='foo1 val01
bar2 val02
foo5 val05
foo2 val2
foo3 val03'
putdebug 1 merge-sshd_config.sh file bar
merge-sshd_config ${file}_7 bar

echo "- include commented line with commentout mode (foo1, bar2, foo5, foo2, foo3) -"
cat <<EOF > ${file}_8
# - include commented line with commentout mode (foo1, bar2, foo5, foo2, foo3) -
foo1 val1
#foo2 val2
#foo3 val3
#foo4 val4
foo5 val5
EOF
bar='foo1 val01
bar2 val02
foo5 val05
foo2 val2
foo3 val03'
putdebug 1 merge-sshd_config.sh file bar
merge-sshd_config -c ${file}_8 bar

echo "- include same keys with commentout mode (foo1, bar2, foo5, foo2, foo3) -"
cat <<EOF > ${file}_9
# - include same keys with commentout mode (foo1, bar2, foo5, foo2, foo3) -
foo1 val1
#foo2 val2
#foo3 val3
#foo1 val3
#foo4 val4
foo5 val5
EOF
bar='foo1 val01
bar2 val02
foo5 val05
foo2 val2
foo3 val03'
putdebug 1 merge-sshd_config.sh file bar
merge-sshd_config -c ${file}_9 bar

echo "- include same keys after (foo1, bar2, foo5, foo2, foo3) -"
cat <<EOF > ${file}_10
# - include same keys after (foo1, bar2, foo5, foo2, foo3) -
#foo1 val1
#foo2 val2
#foo3 val3
foo1 val3
#foo4 val4
foo5 val5
EOF
bar='foo1 val01
bar2 val02
foo5 val05
foo2 val2
foo3 val03'
putdebug 1 merge-sshd_config.sh file bar
merge-sshd_config ${file}_10 bar

echo "- include same keys after with commentout mode (foo1, bar2, foo5, foo2, foo3) -"
cat <<EOF > ${file}_11
# - include same keys after with commentout mode (foo1, bar2, foo5, foo2, foo3) -
#foo1 val1
#foo2 val2
#foo3 val3
foo1 val3
#foo4 val4
foo5 val5
EOF
bar='foo1 val01
bar2 val02
foo5 val05
foo2 val2
foo3 val03'
putdebug 1 merge-sshd_config.sh file bar
merge-sshd_config -c ${file}_11 bar
