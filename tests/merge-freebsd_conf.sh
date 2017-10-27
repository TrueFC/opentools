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
_debug_commands="merge-freebsd_conf"
_debug_functions="merge-freebsd_conf"
_dry_run=true
_dry_run=false

file=../tmp/foo

rm -f ../tmp/*

echo " - include (foo2, foo4, foo5) -"
#_debug=true
cat <<EOF > ${file}_1
# - include (foo2, foo4, foo5) -
Foo: {
	foo1: "This is foo1",
	foo2: val2,
	foo3: "This is foo3",
	foo4: "This is foo4",
	foo5: val5
}
EOF
bar='Foo: {
	foo2: "This is foo2",
	foo4: val4,
	foo5: new_val5
}'
merge-freebsd_conf ${file}_1 bar

echo "- not include (bar1 bar2) -"
#_debug=true
cat <<EOF > ${file}_2
# - not include (bar1 bar2) -
Foo: {
	foo1: "This is foo1",
	foo2: val2,
	foo3: "This is foo3",
	foo4: "This is foo4",
	foo5: val5
}
EOF
bar='Foo: {
	bar1: "This is bar1",
	bar2: bar_val2
}'
merge-freebsd_conf ${file}_2 bar

echo "- partially include (foo2, foo4) -"
#_debug=true
cat <<EOF > ${file}_3
# - partially include (foo2, foo4) -
Foo: {
	foo1: "This is foo1",
	foo2: val2,
	foo3: "This is foo3",
	foo4: "This is foo4",
	foo5: val5
}
EOF
bar='Foo: {
	bar1: "This is bar1",
	foo2: "This is foo2",
	foo4: val4,
	bar2: bar_val2
}'
merge-freebsd_conf ${file}_3 bar

echo "- coiside values (foo2, foo4) -"
#_debug=true
cat <<EOF > ${file}_4
# - coiside values (foo2, foo4) -
Foo: {
	foo1: "This is foo1",
	foo2: val2,
	foo3: "This is foo3",
	foo4: "This is foo4",
	foo5: val5
}
EOF
bar='Foo: {
	foo2: val2,
	foo4: "This is foo4"
}'
merge-freebsd_conf ${file}_4 bar

echo "- include comments (foo2, foo4, bar2) -"
#_debug=true
cat <<EOF > ${file}_5
# - include comments (foo2, foo3, bar2) -
Foo: {
	foo1: "This is foo1",
	foo2: val2,	#	Comments	for	foo2

	# Comments for foo3
	foo3: "This is foo3",
	foo4: "This is foo4",	#	Comments	for	foo4
	foo5: val5
}
EOF
bar='Foo: {
	foo2: val2,
	bar2: "This is bar2", 	#	Comments	for	bar2
	foo3: "This is new_foo3"
}'
merge-freebsd_conf ${file}_5 bar

echo "- include commented line (foo1, foo2, foo3, foo5) -"
#_debug=true
cat <<EOF > ${file}_6
# - include commented line (foo1, foo2, foo3, foo5) -
Foo: {
	foo1: "This is foo1",
#	foo2: val2,
#	foo3: "This is foo3",
#	foo4: "This is foo4",
	foo5: val5
}
EOF
bar='Foo: {
	foo1: val2,
	foo2: "This is foo2",
	bar2: "This is bar2",
	foo5: "This is foo5",
	foo3: "This is new_foo3"
}'
merge-freebsd_conf ${file}_6 bar

echo "- include same keys (foo1, foo2, foo3, foo5) -"
#_debug=true
cat <<EOF > ${file}_7
# - include same keys (foo1, foo2, foo3, foo5) -
Foo: {
	foo1: "This is foo1",
#	foo2: val2,
#	foo3: "This is foo3",
#	foo1: "This is another_foo1",
#	foo4: "This is foo4",
	foo5: val5
}
EOF
bar='Foo: {
	foo1: val2,
	foo2: "This is foo2",
	bar2: "This is bar2",
	foo5: "This is foo5",
	foo3: "This is new_foo3"
}'
merge-freebsd_conf ${file}_7 bar

echo "- include commented line with commentout mode (foo1, foo2, foo3, foo5) -"
#_debug=true
cat <<EOF > ${file}_8
# - include commented line with commentout mode (foo1, foo2, foo3, foo5) -
Foo: {
	foo1: "This is foo1",
#	foo2: val2,
#	foo3: "This is foo3",
#	foo4: "This is foo4",
	foo5: val5
}
EOF
bar='Foo: {
	foo1: val2,
	bar2: "This is bar2",
	foo2: "This is foo2",
	foo5: "This is foo5",
	foo3: "This is new_foo3"
}'
merge-freebsd_conf -c ${file}_8 bar

echo "- include same keys with commentout mode (foo1, foo2, foo3, foo5) -"
#_debug=true
cat <<EOF > ${file}_9
# - include same keys with commentout mode (foo1, foo2, foo3, foo5) -
Foo: {
	foo1: "This is foo1",
#	foo2: val2,
#	foo3: "This is foo3",
#	foo1: "This is another_foo1",
#	foo4: "This is foo4",
	foo5: val5
}
EOF
bar='Foo: {
	foo1: val2,
	foo2: "This is foo2",
	bar2: "This is bar2",
	foo5: "This is foo5",
	foo3: "This is new_foo3"
}'
merge-freebsd_conf -c ${file}_9 bar

echo "- include same keys after with commentout mode (foo1, foo2, foo3, foo5) -"
#_debug=true
cat <<EOF > ${file}_10
# - include same keys after with commentout mode (foo1, foo2, foo3, foo5) -
Foo: {
#	foo1: "This is foo1",
#	foo2: val2,
#	foo3: "This is foo3",
	foo1: "This is another_foo1",
#	foo4: "This is foo4",
	foo5: val5
}
EOF
bar='Foo: {
	foo1: val2,
	foo2: "This is foo2",
	bar2: "This is bar2",
	foo5: "This is foo5",
	foo3: "This is new_foo3"
}'
merge-freebsd_conf -c ${file}_10 bar
