#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. $OPENTOOLSDIR/include/common.inc
. $OPENTOOLSLIBDIR/subc

_debug=false
#_debug=true
_debug_level=1

for i in 1 2 3 4 5 6; do
    setvar comment_$i "Line $i comment"
done

data0='This is line 1 with comment:"$comment_1"
This is line 2 with comment:"$comment_2"
This is line 3 with comment:"$comment_3"
This is line 4 with comment:"$comment_4"
This is line 5 with comment:"$comment_5"
This is line 6 with comment:"$comment_6"'

data1='This is line 1 in nested loop:"$loop"
This is line 2 in nested loop:"$loop"
This is line 3 in nested loop:"$loop"'

data2='%define
OS_UPDATE		yes
NOPORTSBUILD		yes
#PORTS_UPDATE		yes

%pre'

echo '-- simple loop --'
data="$data0"
while pop -t data; do
	pop data
done

_debug=false
#_debug=true
_debug_level=1
echo '-- simple loop with substitution --'
data="$data0"
while pop -t data; do
	pop datum data
	echo $datum
done

_debug=false
#_debug=true
_debug_level=1
echo '-- nested loop --'
data="$data0"
data_1="$data1"
while pop -t data; do
	pop data
	while pop -t data_1; do
		pop data_1
	done
done

echo '-- nested loop with substitution--'
data="$data0"
data_1="$data1"
while pop -t data; do
	pop datum data
	echo "$datum"
	while pop -t data_1; do
		pop datum_1 data_1
		echo "$datum_1"
	done
done

echo '-- Dakefile sample:"%define" in tbedfc --'
data="$data2"
while pop -t data; do
	pop data
done

echo '-- Dakefile sample with substitution:"%define" in tbedfc --'
data="$data2"
while pop -t data; do
	pop datum data
	echo "$datum"
done
