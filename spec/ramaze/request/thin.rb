require 'spec/helper'

testcase_requires 'thin'

def ramaze_options
  { :adapter => :thin }
end

require 'spec/ramaze/request'
