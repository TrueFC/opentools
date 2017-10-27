#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../lib/subc

_debug=false
_debug_level=1

echo "-'right <= width'-"
foo='This is a sample title!'
stremb "$foo"

echo "-'right > width'-"
foo='This is a sample title with over width ....................................!'
stremb "$foo"
