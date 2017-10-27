#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../include/common.inc
. ../lib/subc

_debug=false
_debug_level=1

echo "- key:top -"
key='%key'
str=$(cat <<EOF
%key
This is line-1
This is line-2
This is line-3
This is line-4
This is line-5
EOF
)
str_add='This is add_line-1
This is add_line-2'
splice "$key" str str_add

echo "- key:middle -"
key='%key'
str=$(cat <<EOF
This is line-1
This is line-2
%key
This is line-3
This is line-4
This is line-5
EOF
)
str_add='This is add_line-1
This is add_line-2'
splice "$key" str str_add

echo "- key:bottom -"
key='%key'
str=$(cat <<EOF
This is line-1
This is line-2
This is line-3
This is line-4
This is line-5
%key
EOF
)
str_add='This is add_line-1
This is add_line-2'
splice "$key" str str_add

echo "- key:newline -"
key='%key'
str=$(cat <<EOF
This is line-1
This is line-2
%key
This is line-3
This is line-4
This is line-5
EOF
)
str_add='This is add_line-1
This is add_line-2'
splice -b "$key" str str_add
