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
foo1:val11:val12:val13:val14:val15
foo2:val21:val22:val23:val24:val25
foo3:val31:val33:val33:val34:val35
foo4:val41:val44:val43:val44:val45
foo5:val51:val55:val53:val54:val55
EOF
bar='foo2:val01:val02:val02:val04:val05
foo5:val01:val02:val03:val04:val05'
putdebug 1 merge-passwd.sh file bar
merge-passwd ${file}_1 bar

echo "- not include (bar1, bar2) -"
cat <<EOF > ${file}_2
# - not include (bar1, bar2) -
foo1:val11:val12:val13:val14:val15
foo2:val21:val22:val23:val24:val25
foo3:val31:val33:val33:val34:val35
foo4:val41:val44:val43:val44:val45
foo5:val51:val55:val53:val54:val55
EOF
bar='bar1:val01:val02:val02:val04:val05
bar2:val01:val02:val03:val04:val05'
putdebug 1 merge-passwd.sh file bar
merge-passwd ${file}_2 bar

echo "- partially include (foo2, bar2, foo4) -"
cat <<EOF > ${file}_3
# - partially include (foo2, bar2, foo4) -
foo1:val11:val12:val13:val14:val15
foo2:val21:val22:val23:val24:val25
foo3:val31:val33:val33:val34:val35
foo4:val41:val44:val43:val44:val45
foo5:val51:val55:val53:val54:val55
EOF
bar='foo2:val01:val02:val02:val04:val05
bar2:val01:val02:val03:val04:val05
foo4:val01:val02:val03:val04:val05'
putdebug 1 merge-passwd.sh file bar
merge-passwd ${file}_3 bar

echo "- coiside values  (foo2, foo4) -"
cat <<EOF > ${file}_4
# - coiside values  (foo2, foo4) -
foo1:val11:val12:val13:val14:val15
foo2:val21:val22:val23:val24:val25
foo3:val31:val33:val33:val34:val35
foo4:val41:val44:val43:val44:val45
foo5:val51:val55:val53:val54:val55
EOF
bar='foo2:val21:val22:val23:val24:val25
foo4:val41:val44:val43:val44:val45'
putdebug 1 merge-passwd.sh file bar
merge-passwd ${file}_4 bar

echo "- include comments (foo2, bar2, foo4) -"
cat <<EOF > ${file}_5
# - include comments (foo2, bar2, foo4) -
foo1:val11:val12:val13:val14:val15

foo2:val21:val22:val23:val24:val25	#	Comments	for	foo2
# Comments	for	foo3
foo3:val31:val33:val33:val34:val35
foo4:val41:val44:val43:val44:val45	#	Comments	for	foo4
foo5:val51:val55:val53:val54:val55
EOF
bar='foo2:val01:val02:val02:val04:val05
bar2:val01:val02:val03:val04:val05	#	Comments	for	bar2
foo4:val01:val02:val03:val04:val05'
putdebug 1 merge-passwd.sh file bar
merge-passwd ${file}_5 bar

echo "- include commented line (foo1, bar2, foo5, foo2, foo3) -"
cat <<EOF > ${file}_6
# - include commented line (foo1, bar2, foo5, foo2, foo3) -
foo1:val11:val12:val13:val14:val15
#foo2:val21:val22:val23:val24:val25
#foo3:val31:val33:val33:val34:val35
#foo4:val41:val44:val43:val44:val45
foo5:val51:val55:val53:val54:val55
EOF
bar='foo1:val01:val02:val02:val04:val05
bar2:val01:val02:val03:val04:val05
foo5:val01:val02:val02:val04:val05
foo2:val01:val02:val02:val04:val05
foo3:val01:val02:val03:val04:val05'
putdebug 1 merge-passwd.sh file bar
merge-passwd ${file}_6 bar

echo "- include same keys (foo1, bar2, foo5, foo2, foo3) -"
cat <<EOF > ${file}_7
# - include same keys (foo1, bar2, foo5, foo2, foo3) -
foo1:val11:val12:val13:val14:val15
#foo2:val21:val22:val23:val24:val25
#foo3:val31:val33:val33:val34:val35
#foo1:val31:val33:val33:val34:val35
#foo4:val41:val44:val43:val44:val45
foo5:val51:val55:val53:val54:val55
EOF
bar='foo1:val01:val02:val02:val04:val05
bar2:val01:val02:val03:val04:val05
foo5:val01:val02:val02:val04:val05
foo2:val01:val02:val02:val04:val05
foo3:val01:val02:val03:val04:val05'
putdebug 1 merge-passwd.sh file bar
merge-passwd ${file}_7 bar

echo "- Selected items (bar2, foo2, foo3) -"
cat <<EOF > ${file}_8
# - Selected items (bar2, foo2, foo3) -
foo1:val11:val12:val13:val14:val15
#foo2:val21:val22:val23:val24:val25
#foo3:val31:val33:val33:val34:val35
#foo1:val31:val33:val33:val34:val35
#foo4:val41:val44:val43:val44:val45
foo5:val51:val55:val53:val54:val55
EOF
bar='foo1:val01:val02:val02:val04:val05
bar2:val01:val02:val03:val04:val05
foo5:val01:val02:val02:val04:val05
foo2:val01:val02:val02:val04:val05
foo3:val01:val02:val03:val04:val05'
putdebug 1 merge-passwd.sh file bar
merge-passwd -a "bar2 foo2 foo3" ${file}_8 bar

echo "- Include end with ':' (foo1, bar2, foo5, foo2, foo3) -"
cat <<EOF > ${file}_9
# - Include end with ':' (bar2, foo2, foo3) -
foo1:val11:val12:val13:val14:val15
#foo2:val21:val22:val23:val24:val25
#foo3:val31:val33:val33:val34:
#foo1:val31:val33:val33:val34:
#foo4:val41:val44:val43:val44:val45
foo5:val51:val55:val53:val54:
EOF
bar='foo1:val01:val02:val02:val04:val05
bar2:val01:val02:val03:val04:
foo5:val01:val02:val02:val04:val05
foo2:val01:val02:val02:val04:
foo3:val01:val02:val03:val04:'
putdebug 1 merge-passwd.sh file bar
merge-passwd -a "bar2 foo2 foo3" ${file}_9 bar

echo "- Merge lines from file (bar2, foo2, foo3) -"
cat <<EOF > ${file}_10
# - Merge lines from file (bar2, foo2, foo3) -
foo1:val11:val12:val13:val14:val15
#foo2:val21:val22:val23:val24:val25
#foo3:val31:val33:val33:val34:val35
#foo1:val31:val33:val33:val34:val35
#foo4:val41:val44:val43:val44:val45
foo5:val51:val55:val53:val54:val55
EOF
cat <<EOF > ${file}_10_data
foo1:val01:val02:val02:val04:val05
bar2:val01:val02:val03:val04:val05
foo5:val01:val02:val02:val04:val05
foo2:val01:val02:val02:val04:val05
foo3:val01:val02:val03:val04:val05
EOF
putdebug 1 merge-passwd.sh file bar
merge-passwd -a 'bar2 foo2 foo3' -f '../tmp/foo_10_data' ${file}_10

echo "- Include empty fields  (bar2, foo2, foo3) -"
cat <<EOF > ${file}_11
# - Include empty fields  (bar2, foo2, foo3) -
foo1::val12:val13:val14:val15
#foo2:::val23::val25
#foo3:val31:val33:::
#foo1:val31:val33:val33:val34:val35
#foo4:val41:val44:val43::
foo5:val51:val55:val53:val54:val55
EOF
cat <<EOF > ${file}_11_data
foo1:val01:val02:val02:val04:val05
bar2::val02::val04:
foo5:val01:val02:val02:val04:val05
foo2:val01:val02:val02:val04:val05
foo3:val01:val02:val03:val04:val05
EOF
putdebug 1 merge-passwd.sh file bar
merge-passwd -a 'bar2 foo2 foo3' -f '../tmp/foo_11_data' ${file}_11

echo "- include commented line with commentout mode (foo1, bar2, foo5, foo2, foo3) -"
cat <<EOF > ${file}_12
# - include commented line with commentout mode (foo1, bar2, foo5, foo2, foo3) -
foo1:val11:val12:val13:val14:val15
#foo2:val21:val22:val23:val24:val25
#foo3:val31:val33:val33:val34:val35
#foo4:val41:val44:val43:val44:val45
foo5:val51:val55:val53:val54:val55
EOF
bar='foo1:val01:val02:val02:val04:val05
bar2:val01:val02:val03:val04:val05
foo5:val01:val02:val02:val04:val05
foo2:val01:val02:val02:val04:val05
foo3:val01:val02:val03:val04:val05'
putdebug 1 merge-passwd.sh file bar
merge-passwd -c ${file}_12 bar

echo "- include same keys with commentout mode (foo1, bar2, foo5, foo2, foo3) -"
cat <<EOF > ${file}_13
# - include same keys with commentout mode (foo1, bar2, foo5, foo2, foo3) -
foo1:val11:val12:val13:val14:val15
#foo2:val21:val22:val23:val24:val25
#foo3:val31:val33:val33:val34:val35
#foo1:val31:val33:val33:val34:val35
#foo4:val41:val44:val43:val44:val45
foo5:val51:val55:val53:val54:val55
EOF
bar='foo1:val01:val02:val02:val04:val05
bar2:val01:val02:val03:val04:val05
foo5:val01:val02:val02:val04:val05
foo2:val01:val02:val02:val04:val05
foo3:val01:val02:val03:val04:val05'
putdebug 1 merge-passwd.sh file bar
merge-passwd -c ${file}_13 bar

echo "- Selected items with commentout mode (bar2, foo2, foo3) -"
cat <<EOF > ${file}_14
# - Selected items with commentout mode (bar2, foo2, foo3) -
foo1:val11:val12:val13:val14:val15
#foo2:val21:val22:val23:val24:val25
#foo3:val31:val33:val33:val34:val35
#foo1:val31:val33:val33:val34:val35
#foo4:val41:val44:val43:val44:val45
foo5:val51:val55:val53:val54:val55
EOF
bar='foo1:val01:val02:val02:val04:val05
bar2:val01:val02:val03:val04:val05
foo5:val01:val02:val02:val04:val05
foo2:val01:val02:val02:val04:val05
foo3:val01:val02:val03:val04:val05'
putdebug 1 merge-passwd.sh file bar
merge-passwd -c -a "bar2 foo2 foo3" ${file}_14 bar

echo "- Include end with ':' with commentout mode (foo1, bar2, foo5, foo2, foo3) -"
cat <<EOF > ${file}_15
# - Include end with ':' with commentout mode (bar2, foo2, foo3) -
foo1:val11:val12:val13:val14:val15
#foo2:val21:val22:val23:val24:val25
#foo3:val31:val33:val33:val34:
#foo1:val31:val33:val33:val34:
#foo4:val41:val44:val43:val44:val45
foo5:val51:val55:val53:val54:
EOF
bar='foo1:val01:val02:val02:val04:val05
bar2:val01:val02:val03:val04:
foo5:val01:val02:val02:val04:val05
foo2:val01:val02:val02:val04:
foo3:val01:val02:val03:val04:'
putdebug 1 merge-passwd.sh file bar
merge-passwd -c -a "bar2 foo2 foo3" ${file}_15 bar

echo "- Merge lines from file with commentout mode (bar2, foo2, foo3) -"
cat <<EOF > ${file}_16
# - Merge lines from file with commentout mode (bar2, foo2, foo3) -
foo1:val11:val12:val13:val14:val15
#foo2:val21:val22:val23:val24:val25
#foo3:val31:val33:val33:val34:val35
#foo1:val31:val33:val33:val34:val35
#foo4:val41:val44:val43:val44:val45
foo5:val51:val55:val53:val54:val55
EOF
cat <<EOF > ${file}_16_data
foo1:val01:val02:val02:val04:val05
bar2:val01:val02:val03:val04:val05
foo5:val01:val02:val02:val04:val05
foo2:val01:val02:val02:val04:val05
foo3:val01:val02:val03:val04:val05
EOF
putdebug 1 merge-passwd.sh file bar
merge-passwd -c -a 'bar2 foo2 foo3' -f ${file}_16_data ${file}_16

_dry_run=false
_debug=false
_debug_level=1
echo "- Include empty fields with commentout mode (bar2, foo2, foo3) -"
cat <<EOF > ${file}_17
# - Include empty fields with commentout mode (bar2, foo2, foo3) -
foo1::val12:val13:val14:val15
#foo2:::val23::val25
#foo3:val31:val33:::
#foo1:val31:val33:val33:val34:val35
#foo4:val41:val44:val43::
foo5:val51:val55:val53:val54:val55
EOF
cat <<EOF > ${file}_17_data
foo1:val01:val02:val02:val04:val05
bar2::val02::val04:
foo5:val01:val02:val02:val04:val05
foo2:val01:val02:val02:val04:val05
foo3:val01:val02:val03:val04:val05
EOF
merge-passwd -c -a 'bar2 foo2 foo3' -f ${file}_17_data ${file}_17

_dry_run=true
_debug=false
_debug_level=1
rm -f ../tmp/master.passwd
cp ../tmp/files/master.passwd.dest ../tmp/master.passwd
echo "- Merge master.passwd file (root, admin) -"
merge-passwd -c -a 'root admin' -f ../tmp/files/master.passwd.src ../tmp/master.passwd

_debug=false
_debug_level=1
_dry_run=true
echo "- 'merge -c /etc/master.passwd __foo' -"
merge -c /etc/master.passwd __foo
echo "- 'merge -c -a "root admin" -f /backup/etc/master.passwd /etc/master.passwd' -"
merge -c -a "root admin" -f /backup/etc/master.passwd /etc/master.passwd
echo "- 'mergeio -c /vm/foo/daik0.img:/etc/master.passwd __foo' -"
mergeio -c /vm/foo/daik0.img:/etc/master.passwd __foo
echo "- 'mergeio -c -a "root admin" -f /backup/etc/master.passwd /vm/foo/daik0.img:/etc/master.passwd' -"
mergeio -c -a "root admin" -f /backup/etc/master.passwd /vm/foo/daik0.img:/etc/master.passwd
