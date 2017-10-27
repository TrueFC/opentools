#!/bin/sh

. ../lib/subc

_debug=true
_debug_level=1
_vars="-q --help host"
exclude-vars _vars '-q'
putdebug 1 $0 _vars
