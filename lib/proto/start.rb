require 'rubygems'
require 'ramaze'

# Add the directory this file resides in to the load path, so you can run the
# app from any other working directory
$LOAD_PATH.unshift(__DIR__)

# Initialize controllers and models
require 'controller/init'
require 'model/init'

Ramaze.start(:adapter => :webrick, :port => 7000) if __FILE__ == $0
