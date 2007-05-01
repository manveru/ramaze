#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

testcase_requires 'rubygems'

describe "dependencies" do
  it "no gems" do
    gems = $:.grep(/gems/).reject{|g| g =~ /rspec|rack|systemu/}
    gems.should == []
  end
end
