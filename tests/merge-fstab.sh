#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../include/common.inc
. ../lib/subc
. ../lib/sysrc

_debug=false
_debug_level=1
file=../tmp/foo

rm -f ../tmp/*

echo "- include (foo2, foo5) -"
#_debug=true
cat <<EOF > ${file}_1
# - include (foo2, foo5) -
foo1	val11	val12	val13	val14	val15
foo2	val21	val22	val23	val24	val25
foo3	val31	val33	val33	val34	val35
foo4	val41	val44	val43	val44	val45
foo5	val51	val55	val53	val54	val55
EOF
bar='foo2	val01	val02	val02	val04	val05
foo5	val01	val02	val03	val04	val05'
putdebug 1 merge-fstab.sh file bar
merge-fstab ${file}_1 bar
_debug=false

echo "- not include (bar1 bar2) -"
cat <<EOF > ${file}_2
# - not include (bar1 bar2) -
foo1	val11	val12	val13	val14	val15
foo2	val21	val22	val23	val24	val25
foo3	val31	val33	val33	val34	val35
foo4	val41	val44	val43	val44	val45
foo5	val51	val55	val53	val54	val55
EOF
bar='bar1	val01	val02	val02	val04	val05
bar2	val01	val02	val03	val04	val05'
putdebug 1 merge-fstab.sh file bar
merge-fstab ${file}_2 bar

echo "- partially include (foo2, foo4) -"
cat <<EOF > ${file}_3
# - partially include (foo2, foo4) -
foo1	val11	val12	val13	val14	val15
foo2	val21	val22	val23	val24	val25
foo3	val31	val33	val33	val34	val35
foo4	val41	val44	val43	val44	val45
foo5	val51	val55	val53	val54	val55
EOF
bar='foo2	val01	val02	val02	val04	val05
bar2	val01	val02	val03	val04	val05
foo4	val01	val02	val03	val04	val05'
putdebug 1 merge-fstab.sh file bar
merge-fstab ${file}_3 bar

#_debug=true
echo "- coiside values (foo2, foo4) -"
cat <<EOF > ${file}_4
# - coiside values (foo2, foo4) -
foo1	val11	val12	val13	val14	val15
foo2	val21	val22	val23	val24	val25
foo3	val31	val33	val33	val34	val35
foo4	val41	val44	val43	val44	val45
foo5	val51	val55	val53	val54	val55
EOF
bar='foo2	val21	val22	val23	val24	val25
foo4	val41	val44	val43	val44	val45'
putdebug 1 merge-fstab.sh file bar
merge-fstab ${file}_4 bar

_debug=false
echo "- include comments (foo2, foo4, bar2) -"
cat <<EOF > ${file}_5
# - include comments (foo2, foo4, bar2) -
foo1	val11	val12	val13	val14	val15
foo2	val21	val22	val23	val24	val25	#	Comments	for	foo2

# Comments for foo3
foo3	val31	val33	val33	val34	val35
foo4	val41	val44	val43	val44	val45	#	Comments	for	foo4

foo5	val51	val55	val53	val54	val55
EOF
bar='foo2	val01	val02	val02	val04	val05
bar2	val01	val02	val03	val04	val05	#	Comments	for	bar2
foo4	val01	val02	val03	val04	val05'
putdebug 1 merge-fstab.sh file bar
merge-fstab ${file}_5 bar

echo "- include commented line (foo1, foo2, foo3, foo5) -"
cat <<EOF > ${file}_6
# - include commented line (foo1, foo2, foo3, foo5) -
foo1	val11	val12	val13	val14	val15
#foo2	val21	val22	val23	val24	val25
#foo3	val31	val33	val33	val34	val35
#foo4	val41	val44	val43	val44	val45
foo5	val51	val55	val53	val54	val55
EOF
bar='foo1	val01	val02	val02	val04	val05
bar2	val01	val02	val03	val04	val05
foo5	val01	val02	val02	val04	val05
foo2	val01	val02	val02	val04	val05
foo3	val01	val02	val03	val04	val05'
putdebug 1 merge-fstab.sh file bar
merge-fstab ${file}_6 bar

echo "- include same keys (foo1, foo2, foo3, foo5) -"
cat <<EOF > ${file}_7
# - include same keys (foo1, foo2, foo3, foo5) -
foo1	val11	val12	val13	val14	val15
#foo2	val21	val22	val23	val24	val25
#foo3	val31	val33	val33	val34	val35
#foo1	val31	val33	val33	val34	val35
#foo4	val41	val44	val43	val44	val45
foo5	val51	val55	val53	val54	val55
EOF
bar='foo1	val01	val02	val02	val04	val05
bar2	val01	val02	val03	val04	val05
foo5	val01	val02	val02	val04	val05
foo2	val01	val02	val02	val04	val05
foo3	val01	val02	val03	val04	val05'
putdebug 1 merge-fstab.sh file bar
merge-fstab ${file}_7 bar

echo "- include commented line with commentout mode (foo1, foo2, foo3, foo5) -"
cat <<EOF > ${file}_8
# - include commented line with commentout mode (foo1, foo2, foo3, foo5) -
foo1	val11	val12	val13	val14	val15
#foo2	val21	val22	val23	val24	val25
#foo3	val31	val33	val33	val34	val35
#foo4	val41	val44	val43	val44	val45
foo5	val51	val55	val53	val54	val55
EOF
bar='foo1	val01	val02	val02	val04	val05
bar2	val01	val02	val03	val04	val05
foo5	val01	val02	val02	val04	val05
foo2	val01	val02	val02	val04	val05
foo3	val01	val02	val03	val04	val05'
putdebug 1 merge-fstab.sh file bar
merge-fstab -c ${file}_8 bar

echo "- include same keys with commentout mode (foo1, foo2, foo3, foo5) -"
cat <<EOF > ${file}_9
# - include same keys with commentout mode (foo1, foo2, foo3, foo5) -
foo1	val11	val12	val13	val14	val15
#foo2	val21	val22	val23	val24	val25
#foo3	val31	val33	val33	val34	val35
#foo1	val31	val33	val33	val34	val35
#foo4	val41	val44	val43	val44	val45
foo5	val51	val55	val53	val54	val55
EOF
bar='foo1	val01	val02	val02	val04	val05
bar2	val01	val02	val03	val04	val05
foo5	val01	val02	val02	val04	val05
foo2	val01	val02	val02	val04	val05
foo3	val01	val02	val03	val04	val05'
putdebug 1 merge-fstab.sh file bar
merge-fstab -c ${file}_9 bar

echo "- include same keys after with commentout mode (foo1, foo2, foo3, foo5) -"
cat <<EOF > ${file}_10
# - include same keys after with commentout mode (foo1, foo2, foo3, foo5) -
#foo1	val11	val12	val13	val14	val15
#foo2	val21	val22	val23	val24	val25
#foo3	val31	val33	val33	val34	val35
foo1	val31	val33	val33	val34	val35
#foo4	val41	val44	val43	val44	val45
foo5	val51	val55	val53	val54	val55
EOF
bar='foo1	val01	val02	val02	val04	val05
bar2	val01	val02	val03	val04	val05
foo5	val01	val02	val02	val04	val05
foo2	val01	val02	val02	val04	val05
foo3	val01	val02	val03	val04	val05'
putdebug 1 merge-fstab.sh file bar
merge-fstab -c ${file}_10 bar
