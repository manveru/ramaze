require 'rubygems'
require 'ramaze'

Ramaze.start do |mw|
  mw.run Rack::Directory.new(__DIR__)
end
