#!/usr/bin/env -S ruby -I${OPENTOOLSLIB}
#
# Copyright (c) 2013 Kazuhiko Kiriyama <kiri@OpenEdu.org>
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
# $OpenTools$
#
#comment: Automatic mergemaster
#commandline:
#use: 
#cvs: :pserver:anoncvs@cvs.openedu.org:/home/tcvs automm.rb
#maintainer: kiri@OpenEdu.org
#includes:
#depends:
#description:
#examples:
#

require "getoptlong"
require "fileutils"
require "subc"
if File.exists?('/etc/automm.conf')
  load '/etc/automm.conf'
else
  TEMPROOT = '/var/tmp/temproot'
  EXCLUDE_FILES = {
    '/' => [
      'etc/fstab',
      'etc/group',
      'etc/master.passwd',
      'etc/rc.conf'
    ]
  }
end

SELF_VERSION = %w$OpenTools:$[2]
COMMAND_NAME = File.basename($PROGRAM_NAME)
PROGRAM_NAME = File.basename($PROGRAM_NAME, '.rb')

def main(argv)
  parser = GetoptLong.new
  parser.set_options ['--help', '-h',    GetoptLong::NO_ARGUMENT],
                     ['--dry-run', '-n', GetoptLong::NO_ARGUMENT],
                     ['--force-mergemaster', '-f', GetoptLong::NO_ARGUMENT]
  begin
    parser.each_option do |name, arg|
      eval "$#{name.sub(/^--/, '').gsub(/-/, '_').downcase} = '#{arg}'"
    end
  rescue
    exit 1
  end
  usage if $help
  if not ARGV.empty?
    $destdirs = ARGV
  end

  initialization

  $destdirs.each do |destdir|
    if not EXCLUDE_FILES.include?(destdir)
      error "#{destdir} does not include EXCLUDE_FILES"
    end
  end
  if not File.directory?(TEMPROOT)
    if $dry_run
      puts 'mergemaster -sat ' + TEMPROOT
    else
      system 'mergemaster -sat ' + TEMPROOT
    end
  else
    if $force_mergemaster
      if $dry_run
	puts 'chflags -R noschg ' + TEMPROOT
	puts 'rm -rf ' + TEMPROOT
	puts 'mergemaster -sat ' + TEMPROOT
      else
	backup TEMPROOT
	system 'chflags -R noschg ' + TEMPROOT
	FileUtils.rm_rf(TEMPROOT)
	system 'mergemaster -sat ' + TEMPROOT
      end
    end
  end
  $destdirs.each do |destdir|
    install_files = []
    Dir.glob(TEMPROOT + "/**/*").each do |bkpath|
      install_files << bkpath.sub(/^#{TEMPROOT}\//, '') if not File.directory?(bkpath)
    end
    install_files -= EXCLUDE_FILES[destdir]
    install_files.each do |destpath|
      if $dry_run
	puts 'cp ' + destpath.sub(/^/, TEMPROOT + '/') + ' ' + destdir + destpath
      else
	FileUtils.cp(destpath.sub(/^/, TEMPROOT + '/'), destdir + destpath)
      end
    end
  end
  exit 0
end

def initialization()
  if not $destdirs
    $destdirs = EXCLUDE_FILES.keys
  else
    $destdirs.map!{|destdir| destdir == '/' ? destdir : destdir + '/'}
  end
end

def usage()
  $stderr.print <<-EOF
Usage: #{COMMAND_NAME} [OPTION]... [DEST]...
OpenTools #{PROGRAM_NAME} #{SELF_VERSION}, an updater after make world by mergemaster.
Options:
  -h,  --help               print this help
  -n,  --dry-run            do not actually run, just report the steps
  -f,  --force-mergemaster  force to mergemaster
    EOF
  exit 0
end

if $0 == __FILE__
  exit(main(ARGV) || 1)
end
