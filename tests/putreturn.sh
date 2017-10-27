#!/bin/sh
#-*- tab-width: 4; -*-
# ex:ts=4

. ../include/common.inc
. ../lib/subc

_debug=false
_debug=true
_debug_level=1
tmpdir=../tmp/files
rm -rf $tmpdir
mkdir -p $tmpdir

echo "-- src:file, src.bak:file, src.org:file, --"
touch $tmpdir/foo
touch $tmpdir/foo.bak
touch $tmpdir/foo.org
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:file, src.bak:file, src.org:dir, --"
touch $tmpdir/foo
touch $tmpdir/foo.bak
mkdir $tmpdir/foo.org
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:file, src.bak:dir, src.org:file, --"
touch $tmpdir/foo
mkdir $tmpdir/foo.bak
touch $tmpdir/foo.org
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:dir, src.bak:file, src.org:file, --"
mkdir $tmpdir/foo
touch $tmpdir/foo.bak
touch $tmpdir/foo.org
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:file, src.bak:dir, src.org:dir --"
touch $tmpdir/foo
mkdir $tmpdir/foo.bak
mkdir $tmpdir/foo.org
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:dir, src.bak:file, src.org:dir --"
mkdir $tmpdir/foo
touch $tmpdir/foo.bak
mkdir $tmpdir/foo.org
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:dir, src.bak:dir, src.org:file --"
mkdir $tmpdir/foo
mkdir $tmpdir/foo.bak
touch $tmpdir/foo.org
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:dir, src.bak:dir, src.org:dir --"
mkdir $tmpdir/foo
mkdir $tmpdir/foo.bak
mkdir $tmpdir/foo.org
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:none, src.bak:file, src.org:file --"
touch $tmpdir/foo.bak
touch $tmpdir/foo.org
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:none, src.bak:file, src.org:dir --"
touch $tmpdir/foo.bak
mkdir $tmpdir/foo.org
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:none, src.bak:dir, src.org:file --"
mkdir $tmpdir/foo.bak
touch $tmpdir/foo.org
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:none, src.bak:dir, src.org:dir --"
mkdir $tmpdir/foo.bak
mkdir $tmpdir/foo.org
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:file, src.bak:none, src.org:file --"
touch $tmpdir/foo
touch $tmpdir/foo.org
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:file, src.bak:none, src.org:dir --"
touch $tmpdir/foo
mkdir $tmpdir/foo.org
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:dir, src.bak:none, src.org:file --"
mkdir $tmpdir/foo
touch $tmpdir/foo.org
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:dir, src.bak:none, src.org:dir --"
mkdir $tmpdir/foo
mkdir $tmpdir/foo.org
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:file, src.bak:file, src.org:none --"
touch $tmpdir/foo
touch $tmpdir/foo.bak
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:file, src.bak:dir, src.org:none --"
touch $tmpdir/foo
mkdir $tmpdir/foo.bak
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:dir, src.bak:file, src.org:none --"
mkdir $tmpdir/foo
touch $tmpdir/foo.bak
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:dir, src.bak:dir, src.org:none --"
mkdir $tmpdir/foo
mkdir $tmpdir/foo.bak
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:file, src.bak:none, src.org:none --"
touch $tmpdir/foo
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:dir, src.bak:none, src.org:none --"
mkdir $tmpdir/foo
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:none, src.bak:file, src.org:none --"
touch $tmpdir/foo.bak
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:none, src.bak:dir, src.org:none --"
mkdir $tmpdir/foo.bak
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:none, src.bak:none, src.org:file --"
touch $tmpdir/foo.org
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:none, src.bak:none, src.org:dir --"
mkdir $tmpdir/foo.org
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*

echo "-- src:none, src.bak:none, src.org:none --"
putreturn $tmpdir/foo
ls -lg $tmpdir
rm -rf $tmpdir/*
