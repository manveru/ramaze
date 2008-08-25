require 'rubygems'
require 'ramaze'

# Initialize controllers and models
require 'controller/init'
require 'model/init'

Ramaze.start :adapter => :webrick, :port => 7000
