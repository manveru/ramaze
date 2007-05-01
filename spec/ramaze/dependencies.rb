#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

testcase_requires 'rubygems'

describe "dependencies" do
  it "no gems" do
    # rspec, systemu and syntax (loaded by rspec since 0.9)
    # are used for testing
    regex = /rspec|rack|systemu|syntax/
    gems = $:.grep(/gems/).reject{|g| g =~ regex}
    gems.should == []
  end
end
