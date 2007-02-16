require 'spec/spec_helper'

testcase_requires 'mongrel'

def ramaze_options
  { :adapter => :mongrel }
end

require 'spec/request_tc_helper'
