require 'rubygems'
require 'open-uri'
require 'spec'
$:.unshift File.join(File.dirname(File.expand_path(__FILE__)), '..', 'lib')
require 'ramaze'

Ramaze::Global.mode = :silent
Ramaze::Global.run_loose = true
Ramaze::Global.error_page = false
