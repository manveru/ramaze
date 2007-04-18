require 'spec/helper'

testcase_requires 'mongrel'

def ramaze_options
  { :adapter => :mongrel }
end

require 'spec/ramaze/request'
