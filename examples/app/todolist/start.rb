require 'rubygems'
require 'ramaze'

Ramaze.setup do
  gem 'sequel'
end

require 'controller/init'
require 'model/init'

Ramaze.start
