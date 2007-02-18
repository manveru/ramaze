#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'

testcase_requires 'webrick'

def ramaze_options
  { :adapter => :webrick }
end

require 'spec/adapter_spec'
