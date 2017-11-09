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
require "sdoc.inc"

def main(argv)
  parser = GetoptLong.new
  parser.set_options ['--dry-run',              '-n', GetoptLong::NO_ARGUMENT],
                     ['--force-https',          '-s', GetoptLong::NO_ARGUMENT],
                     ['--leap-day',             '-L', GetoptLong::NO_ARGUMENT],
                     ['--long-help',  '--help',       GetoptLong::NO_ARGUMENT],
                     ['--short-help',           '-h', GetoptLong::NO_ARGUMENT],
                     ['--template-file',        '-t', GetoptLong::REQUIRED_ARGUMENT]
  begin
    parser.each_option do |name, arg|
      eval "$#{name.sub(/^--/, '').gsub(/-/, '_').downcase} = '#{arg}'"
    end
  rescue
    exit 1
  end
  usage if $long_help or $short_help

  initialization

  case $page_type
  when :leap_day
    template = readfile $templatefile, :string
    src      = readfile $srcfile, :string
    src.gsub! %r|http://|m, "https://" if $force_https
    src.gsub! /\A.*?\n(<h\d+ .*?)\n<div class=\"navigatorbottom\">\n.*?\z/m, "\\1"
    src.gsub! /\n(<div class=\"titletoc\">\n.*?)\n<\/div>/m, ""
    dest     = []
    src.split(/\n/).each do |line| 
      if line =~ /^<h\d+ /
	level, id, content = line.scan(%r|^<h(\d+) id=\"([^\"]+)\">([^<]+)</h\d+>$|)[0]
	if level.to_i > 1
	  level = level.to_i - 1
	end
	dest << "<h#{level}><a id=\"#{id}\" class=\"anchor\" href=\"##{id}\" aria-hidden=\"true\"><span aria-hidden=\"true\" class=\"octicon octicon-link\"></span></a>#{content}</h#{level}>"
      else
	dest << line
      end
    end
    dest = template.gsub /%%CONTENTS%%/, dest.join("\n") + "\n"
    dest.gsub! /\n\s*<!-- Changed by: .*?-->/m, ""
    writefile $destfile, dest
  else
    error "Unknown page type: \`#{page_type.to_s}'"
  end
  exit 0
end

def initialization()
  if ARGV.size != 2
    error "both source and destination file must be specified"
  else
    $srcfile  = ARGV[0]
    $destfile = ARGV[1]
  end
  if $leap_day
    $page_type = :leap_day
  else
    $page_type = :unknown
  end
  case $page_type
  when :leap_day
    if $template_file
      $templatefile = $template_file 
    else
      $templatefile = OPENTOOLSTMPLDIR + '/github/pages/LeapDay.html'
    end
  else
    error "Unknown page type: \`#{$page_type.to_s}'"
  end
end

def usage()
  if $short_help
    $stderr.print <<-EOF
Usage: #{COMMAND_NAME} [-Lhns] file file
    EOF
  elsif $long_help
    $stderr.print <<-EOF
OpenTools #{PROGRAM_NAME} #{$version}, a GitHub page generator from SmartDoc html.

Usage: #{COMMAND_NAME} [-Lhns] file file
   2 files must be specified. 1st one is SmartDoc's compiled html file to be
   included in GitHub pages, 2nd one is GitHub page html file to which convert
   with type by specified option that is -L for \`Lead Day'.

Options:
  -h,--help            Print this help.
  -n,--dry-run         Do not actually run, just report the steps.
  -L,--leap-day        Set GitHub template page \`Lead Day'.
  -s,--force-https     Force enable to https connection.
  -t,--template-file <template file>
                       Use <template file> for GitHub page.
                       Default: /usr/local/opentools/Templates/github/pages/*
    EOF
  end
  exit 0
end

if $0 == __FILE__
  exit(main(ARGV) || 1)
end
