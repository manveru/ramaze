require 'rubygems'
require 'ramaze'

Ramaze.setup do
  gem 'sequel'
end

require __DIR__'controller/init'
require __DIR__'model/init'

Ramaze.start
