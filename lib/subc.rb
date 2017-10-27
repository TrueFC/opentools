#-*- mode:ruby -*-
#
# Copyright (c) 2012 Kazuhiko Kiriyama <kiri@OpenEdu.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $OpenTools: lib/subc.rb,v 1.4 2013/03/03 05:05:39 kiri Exp $
#
#comment: SUB Commands referenced by opentools' ruby command
#commandline:
#use: 
#cvs: :pserver:anoncvs@cvs.openedu.org:/home/tcvs lib/subc.rb
#maintainer: kiri@OpenEdu.org
#includes:
#depends:
#description:
#examples:
#

require 'fileutils'

YEAR         = Time.now.year
NEN          = YEAR - 1988
MONTH        = Time.now.month
YEARTH       = ENV['YEARTH'] ? ENV['YEARTH'].to_i : MONTH < 4 ? YEAR - 1 : YEAR
NENDO        = ENV['NENDO'] ? ENV['NENDO'].to_i : YEARTH - 1988

FreeBSD_ETCDIR = '/etc'
FreeBSD_SRCDIR = '/usr/src'

def warn(message)
  $stderr.printf "Warning: %s\n", message
end

def error(message)
  $stderr.printf "Error: %s\n", message
  exit 1
end

def readfile(path, mode = :array)
  case mode
  when :array
    IO.readlines(path).map {|line| line.chomp}
  when :string
    IO.readlines(path, nil)[0]
  end
end

def writefile(path, string, mode = :write)
  case mode
  when :write
    fd = open(path, "w")
  when :append
    fd = open(path, "a")
  end
  fd.puts string.rstrip
  fd.close
end

def backup(file)
  if File.exist?(file) and
      not File.exist?("#{file}.org") and
      not File.exist?("#{file}.bak")
    FileUtils.copy file, file + '.org'
  elsif not File.exist?(file) and
      not File.exist?("#{file}.org") and
      not File.exist?("#{file}.bak")
  elsif File.exist?(file)
    FileUtils.copy file, file + '.bak'
  end
end

def draw_salt(format)
  salt_chars = 
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789./'
  case format
  when :des
    idx1 = (rand() * salt_chars.length).to_i
    idx2 = (rand() * salt_chars.length).to_i
    chr1 = salt_chars[idx1, 1]
    chr2 = salt_chars[idx2, 1]
    return chr1 + chr2
  when :md5
    core = ''
    for i in 1 .. 8
      core += salt_chars[(rand() * salt_chars.length).to_i, 1]
    end
    return "\$1\$#{core}\$"
  end
end

def encode_passwd(passwd, type)
  srand(Time.now.tv_sec ^ ($$ + ($$ << 15)))
  passwd.crypt(draw_salt(type))
end

