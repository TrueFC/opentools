#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../lib/subc

_debug=false
_debug_level=1

echo "-\"foo\"-\"bar\"-"
foo='foo:Line 1
foo:Line 2
foo:Line 3'
bar='bar:Line 1
bar:Line 2'
append foo bar
echo "$foo"

echo "-\"\"-\"bar\"-"
foo=''
bar='bar:Line 1
bar:Line 2'
append foo bar
echo "$foo"

echo "-\"foo\"-\"\"-"
foo='foo:Line 1
foo:Line 2
foo:Line 3'
bar=''
append foo bar
echo "$foo"

echo "-\"\"-\"\"-"
foo=''
bar=''
append foo bar
echo "$foo"

echo "-\"foo\"-\"bar\"-"
foo='foo:Line 1
foo:Line 2
foo:Line 3

'
bar='bar:Line 1
bar:Line 2


'
append foo bar
echo "$foo"

echo "-insert after \"%baz\"-"
foo='foo:Line 1
%baz
foo:Line 2
foo:Line 3'
bar='bar:Line 1
bar:Line 2'
append -k "%baz" foo bar
echo "$foo"
