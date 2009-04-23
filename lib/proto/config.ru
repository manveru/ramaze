#!/usr/bin/env rackup
#
# config.ru for ramaze apps
# use thin >= 1.0.0
# thin start -R config.ru
#
# rackup is a useful tool for running Rack applications, which uses the
# Rack::Builder DSL to configure middleware and build up applications easily.
#
# rackup automatically figures out the environment it is run in, and runs your
# application as FastCGI, CGI, or standalone with Mongrel or WEBrick -- all from
# the same configuration.

require File.expand_path('app', File.dirname(__FILE__))
Ramaze.start(:file => __FILE__, :started => true)
run Ramaze
