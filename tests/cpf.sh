#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. $OPENTOOLSDIR/include/common.inc
. $OPENTOOLSLIBDIR/subc
_debug=true
_debug_mode=module
_debug=false
_debug_level=1
_debug_commands="cpf"
_debug_functions="cpf"
_dry_run=true
_dry_run=false

cd ../tmp

echo '-- cpf foo bar --'
rm -rf foo bar
touch foo bar
cpf foo bar
ls -lg bar

echo '-- cpf foo bar/baz --'
rm -rf foo bar
touch foo
mkdir bar
cpf foo bar/baz
ls -lg bar

echo '-- cpf foo bar/baz : bar not exists--'
rm -rf foo bar
touch foo
cpf foo bar/baz

echo '-- cpf foo bar : bar not exists --'
rm -rf foo bar
touch foo
cpf foo bar
ls -lg bar

echo '-- cpf foo foo1 foo2 bar : bar is dir --'
rm -rf foo* bar*
mkdir bar
touch foo foo1 foo2
cpf foo foo1 foo2 bar
ls -lg bar

echo '-- cpf foo foo1 foo2 bar : bar is file --'
rm -rf foo* bar*
touch foo foo1 foo2 bar
cpf foo foo1 foo2 bar

echo '-- cpf foo foo1 foo2 bar : foo,foo2 not exist --'
rm -rf foo* bar*
mkdir bar
touch foo1
cpf foo foo1 foo2 bar
ls -lg bar

echo '-- cpf foo foo1 foo2 bar : bar not exists --'
rm -rf foo* bar*
touch foo foo1 foo2
cpf foo foo1 foo2 bar

echo '-- cpf foo foo1 foo2 bar : foo,foo1,foo2 not exist --'
rm -rf foo* bar*
mkdir bar
cpf foo foo1 foo2 bar
ls -lg bar
