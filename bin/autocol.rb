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
require "html.inc"

def main(argv)
  parser = GetoptLong.new
  parser.set_options ['--dry-run',              '-n', GetoptLong::NO_ARGUMENT],
                     ['--long-help',  '--help',       GetoptLong::NO_ARGUMENT],
                     ['--short-help',           '-h', GetoptLong::NO_ARGUMENT]
  begin
    parser.each_option do |name, arg|
      eval "$#{name.sub(/^--/, '').gsub(/-/, '_').downcase} = '#{arg}'"
    end
  rescue
    exit 1
  end
  usage if $long_help or $short_help
  if not ARGV.empty?
    $targefiles = ARGV
  end

  initialization

  $targefiles.each do |targefile|
    targethtml = readfile(targefile, :string)
    targethtml.gsub!(/<colgroup .*?<\/colgroup>/m) do |colgroup|
      attrib_colgroup, colstr = colgroup.scan(/<colgroup *([^>]*?)>(.*?)<\/colgroup>/m)[0]
      next if not colstr =~/<col [^>]*?width="[\.\d]+em"/
      cols = []
      totalwidth = 0
      colstr.strip.split(/\n/).each do |col|
	attribs_col = {}
	col.scan(/(\w+)="(\S+)"/) do |attrib, value|
	  attribs_col[attrib] = value
	end
	totalwidth += attribs_col['width'].scan(/^([\.\d]+)em/)[0][0].to_f
	cols << attribs_col
      end
      cols.map! do |col|
	percentage = col['width'].scan(/^([\.\d]+)em/)[0][0].to_f / totalwidth.to_f * 100
	col['width'] = percentage.to_i.to_s + '%'
	col
      end
      '<colgroup ' + attrib_colgroup + '>' + "\n" + 
	cols.map{|col|
	'<col ' + 
	  col.keys.map {|attrib| attrib + '="' + col[attrib] + '"'}.join(' ') +
	  ' />'}.join("\n") + "\n" +
	'</colgroup>'
    end
    if not $dry_run
      backup targefile
      writefile targefile, targethtml
    else
      puts targethtml
    end
  end
  exit 0
end

def initialization()
end

def usage()
  if $short_help
    $stderr.print <<-EOF
Usage: #{COMMAND_NAME} [-n] [-h|--help] file ...
    EOF
  elsif $long_help
    $stderr.print <<-EOF
OpenTools #{PROGRAM_NAME} #{$version}, html table column size auto adjuster.

Usage: #{COMMAND_NAME} [-n] [-h|--help] file ...
  Convert HTML table column width with em scale within file to % scale.
  HTML files are assumed to be regular format like XHTML and table column sizes
  thought to be described with width attribute of col tag in colgroup.

Options:
  -h                print shot help
  --help            print this help
  -n,  --dry-run    do'nt actually run, just report the steps
    EOF
  end
  exit 0
end

if $0 == __FILE__
  exit(main(ARGV) || 1)
end
