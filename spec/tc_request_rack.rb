require 'spec/spec_helper'

#testcase_requires 'rack', 'mongrel'

def ramaze_options
  {
    :adapter => :rack
  }
end

require 'spec/request_tc_helper'
