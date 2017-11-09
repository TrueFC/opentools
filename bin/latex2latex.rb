#!/usr/bin/env -S OPENTOOLSDIR=%%OPENTOOLSDIR%% ruby %%RUBY_ARGS%% -I%%OPENTOOLSDIR%%/include
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
require "latex.inc"

def main(argv)
  parser = GetoptLong.new
  parser.set_options ['--dry-run',              '-n', GetoptLong::NO_ARGUMENT],
                     ['--long-help',  '--help',       GetoptLong::NO_ARGUMENT],
                     ['--newpage-section',      '-N', GetoptLong::NO_ARGUMENT],
                     ['--proc-section',         '-s', GetoptLong::REQUIRED_ARGUMENT],
                     ['--processing',           '-p', GetoptLong::REQUIRED_ARGUMENT],
                     ['--short-help',           '-h', GetoptLong::NO_ARGUMENT],
                     ['--titlepage',            '-T', GetoptLong::REQUIRED_ARGUMENT]
                     
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
  $mode_global.each do |mode, value|
    case mode
    when :newpage_section
      if not src.already_newpage_section?
	src.force_newpage_before_section!
	$source_changed = true
      else
	warn "\`newpage_section\' already done."
      end
    when :titlepage
      style = $mode_global[:titlepage]
      if not src.already_titlepage? style
	src.setting_titlepage! style
	$source_changed = true
      else
	warn "\`titlepage\' already done."
      end
    end
  end
  if $mode
    preamble, body, postamble = src.scan(/\A(.*?)(\\section{.*)(\\end{document})\s*\z/m)[0]
    case $mode
    when :proc_section
      nsection = 1
      src = preamble
      body.scan(/(\\section{.*?)(?=(?:\\section{|\z))/m).each do |section|
	content = section[0]
	if $proc_sections.keys.include?(nsection)
	  $proc_sections[nsection].each do |proc|
	    case proc
	    when :banner_longtable
	      head, tail = content.scan(/^(\A.*?\\endlastfoot\n)(.*)\z/m)[0]
	      if head
		if not head.already_banner_longtable?
		  head.sub! /(\\endhead\s+)/, "\\1\\\\hline\n"
		  case LOCALE
		  when :ja
		    head.sub! /continued from previous page/, "前のページからの続き"
		    head.sub! /continued on next page/, "次のページに続く"
		  end
		  tail.gsub!(/\s*\\hline$/, "").sub!(/(\s*\\end{longtable})/m, "\\\\hline\\1")
		  content = head + tail
		  $source_changed = true
		else
		  warn "\`banner_longtable\' already done."
		end
	      else
		warn "\`longtable\' not found."
	      end
	    else
	      warn "unkown processing \`#{proc}\'"
	    end
	  end
	end
	src += content
	nsection += 1
      end
      src += postamble
    end
  end
  if $source_changed
    writefile $destfile, src 
  else
    warn "all processing already done. \`#{$destfile}\' does not changed."
  end
  exit 0
end

class String
  def already_newpage_section?
    if self.scan(/\\section{.*?}/m).size == self.scan(/\\newpage\s*\\section{.*?}/m).size
      return true
    else
      return false
    end
  end

  def already_banner_longtable?
    if self =~ /\\endhead\s+\\hline\n/
      return true
    else
      return false
    end
  end

  def already_titlepage?(style)
    case style
    when :legal
      self =~ /^A.*\\homepage{.*?\\begin{document}/m
    else
      warn "title page style \`#{style}\' does not supported."
      true
    end
  end

  def force_newpage_before_section!
    self.gsub! /([^\s(?:\\newpage)]+\s*)(\\section{.*?})/m, "\\1\\\\newpage\n\\2"
  end

  def setting_titlepage!(style)
    case style
    when :legal
      if DOCVERSION
	version, rivision = DOCVERSION.split(/\./)
      else
	error "\`DOCVERSION\' must be specified."
      end
      author, email, homepage = self.scan(%r|\\author{(.*?)\\\\(.*?)\\\\(.*)}$|)[0]
      self.sub! /\\author{.*}$(.*?\\begin{document})/m, "\\\\version{#{version}}\n\\\\rivision{#{rivision}}\n\\\\author{#{author}}\n\\\\email{#{email}}\n\\\\homepage{#{homepage}}\\1"
    else
      warn "title page style \`#{style}\' does not supported."
      true
    end
  end
end

def initialization()
  if ARGV.size < 1
    error "file to be cropping must be specified"
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
  $mode_global[:newpage_section] = true if $newpage_section
  $mode_global[:titlepage]       = $titlepage.to_sym if $titlepage
  $mode                          = :proc_section if $proc_section
  if $mode
    case $mode
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
end

def usage()
  if $short_help
    $stderr.print <<-EOF
Usage: #{COMMAND_NAME} [-Nn] [-h|--help] [-s range -p proc] [-T style] [[file] file]
    EOF
  elsif $long_help
    $stderr.print <<-EOF
OpenTools #{PROGRAM_NAME} #{$version}, a LaTeX source processor.

Usage: #{COMMAND_NAME} [-Nn] [-h|--help] [-s range -p proc] [-T style] [[file] file]
  Processing LaTeX source file and put it destination file.
  files are specified by source and destination order. If source
  file omitted, inplace mode asummed and specified file converted
  to itself.

  range and proc are section\'s range and determin processing modes.
  These must be corresponding each other.

Options:
  -h                print shot help
  --help            print this help
  -N,  --newpage-section
                    force to newpage at every section
  -n,  --dry-run    do not actually run, just report the steps
  -s range, --proc-section=range
                    processing sections over range. range should be
                    1-3 or 1,2,3 format.
  -p proc, --processing=proc
                    processing each sections for each range. proc
                    should be specified by symbolic name separated 
                    by colon in which specify processings separated
                    by comma in each range. Now supported \`banner_longtable\'.
  -T style,  --titlepage=style
                    setting title page to \`style\'. Now supported
                    \`legal\'.
    EOF
  end
  exit 0
end

if $0 == __FILE__
  exit(main(ARGV) || 1)
end
