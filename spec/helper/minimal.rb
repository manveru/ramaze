require 'timeout'

base = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
$:.unshift base.gsub(/^#{Dir.pwd}/, '.')

# $VERBOSE = 1
$context_runner = false

require 'ramaze'

begin
  require 'rubygems'
rescue LoadError => ex
end

require 'spec'
if Spec::VERSION::FULL_VERSION < "0.9.1 (r1880)"
  puts "please update rspec >= 0.9.1"
  exit 1
end
