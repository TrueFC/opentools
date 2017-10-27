#!/usr/bin/env -S ruby ${RUBY_ARGS} -I${OPENTOOLSDIR}/include
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

require "getoptlong"
require "fileutils"
require "common.inc"
require "sdoc.inc"

def main(argv)
  parser = GetoptLong.new
  parser.set_options ['--crop-section',         '-c', GetoptLong::REQUIRED_ARGUMENT],
                     ['--dry-run',              '-n', GetoptLong::NO_ARGUMENT],
                     ['--long-help',  '--help',       GetoptLong::NO_ARGUMENT],
                     ['--proc-section',         '-s', GetoptLong::REQUIRED_ARGUMENT],
                     ['--processing',           '-p', GetoptLong::REQUIRED_ARGUMENT],
                     ['--short-help',           '-h', GetoptLong::NO_ARGUMENT]
  begin
    parser.each_option do |name, arg|
      eval "$#{name.sub(/^--/, '').gsub(/-/, '_').downcase} = '#{arg}'"
    end
  rescue
    exit 1
  end
  usage if $short_help or $long_help

  initialization

  src = readfile $srcfile, :string
  preamble, body, postamble = src.scan(%r@\A(.*?)(<section\s+.*?>.*</section>\s*)(.*)\z@m)[0]
  src = preamble
  case $mode
  when :crop_section
    nsection = 1
    body.scan(%r@(<section\s+.*?</section>\s*)@m).each do |section|
      content = section[0]
      if not $crop_sections.include?(nsection)
	src += content
      end
      nsection += 1
    end
  when :proc_section
    nsection = 1
    body.scan(%r@(<section\s+.*?</section>\s*)@m).each do |section|
      content = section[0]
      if $proc_sections.keys.include?(nsection)
	$proc_sections[nsection].each do |proc|
	  case proc
	  when :delete_anchor
	    content.gsub! /<a\s+.*?>(.*?)<\/a>/m, "\\1"
	  else
	    warn "unkown processing \`#{proc}\'"
	  end
	end
      end
      src += content
      nsection += 1
    end
  end
  src += postamble
  writefile $destfile, src
  exit 0
end

def initialization()
  if ARGV.size < 1
    error "file to be processing must be specified"
  elsif ARGV.size < 2
    warn "specified file is to be overwritten"
    $srcfile  = ARGV[0]
    $destfile = ARGV[0]
  elsif ARGV.size < 3
    $srcfile  = ARGV[0]
    $destfile = ARGV[1]
  else
    error "too many arguments"
  end
  $mode = :crop_section if $crop_section
  $mode = :proc_section if $proc_section
  case $mode
  when :crop_section
    $crop_sections = []
    if $crop_section =~ /^(\d+)-(\d+)$/
      for i in $1..$2
	$crop_sections << i
      end
    elsif $crop_section =~ /^(\d+)(:?,(\d+))*?$/
      $crop_sections = $&.split(/,/).map{|digit| digit.to_i}
    else
      error "wrong crop argument: \`#{$crop_sections}'"
    end
  when :proc_section
    $proc_sections = {}
    if $proc_section =~ /^(\d+)-(\d+)$/
      for section in $1..$2
	$proc_sections[section] = nil
      end
    elsif $proc_section =~ /^(\d+)(:?,(\d+))*?$/
      $&.split(/,/).map{|digit| digit.to_i}.each do |section|
	$proc_sections[section] = nil
      end
    else
      error "wrong proc argument: \`#{$proc_sections}'"
    end
    if not $processing
      error "corresponging processing must be specifies for \`#{$proc_sections}'"
    elsif $processing.split(/:/).size != $proc_sections.size
      error "processings does not corresponding to \`#{$proc_sections}'"
    else
      processings = []
      if $processing =~ /^([\w,]+)(?:\:([\w,]+))*?$/
	processing = $&
	processing.split(/:/).each do |procs|
	  individual_procs = []
	  procs.split(/,/).each do |proc|
	    individual_procs << proc.to_sym
	  end
	  processings << individual_procs
	end
      else
	error "wrong processing argument: \`#{$processing}'"
      end
      i = 0
      $proc_sections.keys.sort.each do |section|
	$proc_sections[section] = processings[i]
	i += 1
      end
    end
  else
    error "Unknown mode: \`#{$mode.to_s}'"
  end
end

def usage()
  if $short_help
    $stderr.print <<-EOF
Usage: #{COMMAND_NAME} [-h|--help] [-n] [{-c range|-s range -p proc} [file] file]
    EOF
  elsif $long_help
    $stderr.print <<-EOF
OpenTools #{PROGRAM_NAME} #{$version}, a SmartDoc source processor.

Usage: #{COMMAND_NAME} [-h|--help] [-n] [{-c range|-s range -p proc} [file] file]
  Processing SmartDoc source file and put it destination file.
  files are specified by source and destination order. If source
  file omitted, inplace mode asummed and specified file converted
  to itself.

  \`-s\' option\'s range and \`-p\' option\'s proc are SmartDoc
  section\'s range and it\'s corresponding processing modes
  respectively. 

  \`-c\' and \`-s\' are exclusive options.

Options:
  -c range, --crop-section=range
                    crop sections over range. range should be
                    1-3 or 1,2,3 format.
  -h                print shot help
  --help            print this help
  -n,  --dry-run    do not actually run, just report the steps
  -p proc, --processing=proc
                    processing each sections for each range. proc
                    should be specified by symbolic name separated 
                    by colon in which specify processings separated
                    by comma in each range. Now supported \`delete_anchor\'.
  -s range, --proc-section=range
                    processing sections over range. range should be
                    1-3 or 1,2,3 format.
    EOF
  end
  exit 0
end

if $0 == __FILE__
  exit(main(ARGV) || 1)
end
