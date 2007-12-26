#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'timeout'

begin
  require 'rubygems'
rescue LoadError => ex
end

base = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
$:.unshift base.gsub(/^#{Regexp.escape(Dir.pwd)}/, '.')

# $VERBOSE = 1
$context_runner = false

require 'ramaze'

require 'spec'
if Spec::VERSION::FULL_VERSION < "1.0.3 (r2035)"
  puts "please update rspec >= 1.0.3"
  exit 1
end
