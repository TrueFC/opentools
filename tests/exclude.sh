#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. $OPENTOOLSDIR/include/common.inc
. $OPENTOOLSLIBDIR/subc
_debug=true
_debug_mode=module
_debug=false
_debug_level=1
_debug_commands="exclude"
_debug_functions="exclude"
#_dry_run=true

echo '-- exclude "item2" from "item item1 item2 item3 item4"  --'
items="item item1 item2 item3 item4"
exclude items item2
echo $items

echo '-- exclude "item2 item item3" from "item item1 item2 item3 item4"  --'
items="item item1 item2 item3 item4"
exclude items "item2 item item3"
echo $items

echo '-- exclude one item with sep=",": "item2" from "item item1 item2 item3 item4"  --'
items="item item1 item2 item3 item4"
exclude -s , items item2
echo $items

echo '-- exclude with sep=",": "item2 item item3" from "item item1 item2 item3 item4"  --'
items="item item1 item2 item3 item4"
exclude -s , items item2,item,item3
echo $items
