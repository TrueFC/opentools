#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../lib/subc

_debug=true
_debug_level=1

foo='This is foo'
putdebug 1 reuse.sh:1 foo __foo__
unuse foo
putdebug 1 reuse.sh:2 foo __foo__
reuse foo
putdebug 1 reuse.sh:3 foo __foo__
