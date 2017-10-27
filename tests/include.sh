#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../lib/subc

_debug=false
_debug_level=1

echo -n "--test1:"
str="foo bar baz foo1 bar1 baz1"
if include "$str" bar foo1 baz1; then
	echo "'$str' include 'bar foo1 baz1'"
else
	echo "'$str' NOT include 'bar foo1 baz1'"
fi	

echo -n "--test2:"
str="foo bar baz foo1 bar1 baz1"
if include "$str" bar foo1 nantara; then
	echo "'$str' include 'bar foo1 nantara'"
else
	echo "'$str' NOT include 'bar foo1 nantara'"
fi	

echo -n "--test3:"
str="foo"
if include "$str" bar foo nantara; then
	echo "'$str' include 'bar foo nantara'"
else
	echo "'$str' NOT include 'bar foo nantara'"
fi	

echo -n "--test4:"
str="foo bar baz foo1 bar1 baz1"
if include "$str" bar2 foo2; then
	echo "'$str' include 'bar2 foo2'"
else
	echo "'$str' NOT include 'bar2 foo2'"
fi	
