require 'rubygems'
require 'open-uri'
require 'spec'
$:.unshift File.join(File.dirname(File.expand_path(__FILE__)), '..', 'lib')
require 'ramaze'

Ramaze::Global.running_adapter.kill if Ramaze::Global.running_adapter
