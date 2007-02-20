#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'

testcase_requires 'rubygems'

context "dependencies" do
  specify "no gems" do
    gems = $:.grep(/gems/).reject{|g| g =~ /rspec/}
    gems.should == []
  end
end
