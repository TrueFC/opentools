#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../lib/subc

_debug=false
_debug_level=1

foo='item1 item2 item3 item4 item5'
bar='item2 item5'
echo "${foo}" | awk -v items="${bar}" "${exclude_items_awk}"
bar='item1 item3 item4'
echo "${foo}" | awk -v items="${bar}" "${exclude_items_awk}"
bar=''
echo "${foo}" | awk -v items="${bar}" "${exclude_items_awk}"
bar='item1 item2 item3 item4 item5'
echo "${foo}" | awk -v items="${bar}" "${exclude_items_awk}"
bar='item9 item2 item13 item4 item15'
echo "${foo}" | awk -v items="${bar}" "${exclude_items_awk}"
