#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../include/common.inc

CREATE_PORTSTREE_VERSION=1.0
eval VERSION=\${`echo ${PROGRAM_NAME} | tr '-' '_' | tr "[[:lower:]]" "[[:upper:]]"`_VERSION}

echo 'VERSION='\"${VERSION}\"
