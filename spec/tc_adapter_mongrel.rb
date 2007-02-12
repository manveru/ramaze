#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'

testcase_requires 'mongrel'

include Ramaze

class TCAdapterController < Template::Ezamar
  def index
    "The index"
  end
end

context "Mongrel" do
  context "multiple" do
    ramaze :mapping => {'/' => TCAdapterController}, :port => '7001..7003', :adapter => :mongrel

    specify "simple request" do
      get('/').should == "The index"
    end
  end
end
