#!/usr/bin/env ruby

# Use this file directly like `ruby start.rb` if you don't want to use the
# `ramaze start` command.
# All application related things should go into `app.rb`, this file is simply
# for options related to running the application locally.

require File.expand_path('../app', __FILE__)

Ramaze.start(:adapter => :webrick, :port => 7000, :file => __FILE__)
