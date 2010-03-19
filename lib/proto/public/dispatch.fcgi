#!/usr/bin/env ruby

require 'rubygems'
require 'ramaze'

# FCGI doesn't like you writing to stdout
Ramaze::Log.loggers = [ Ramaze::Logger::Informer.new( __DIR__("../ramaze.fcgi.log") ) ]
Ramaze.options.adapter = :fcgi

$0 = __DIR__("../start.rb")
require $0
