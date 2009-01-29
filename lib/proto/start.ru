#!/usr/bin/env rackup
#
# start.ru for ramaze apps
# use thin >= 1.0.0
# thin start -R start.ru
#
# rackup is a useful tool for running Rack applications, which uses the
# Rack::Builder DSL to configure middleware and build up applications easily.
#
# rackup automatically figures out the environment it is run in, and runs your
# application as FastCGI, CGI, or standalone with Mongrel or WEBrick—all from
# the same configuration.

cwd = File.dirname(__FILE__)
require "#{cwd}/start"
Innate.start(:started => true)
run Innate.middleware(:innate)
