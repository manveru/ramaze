#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'

include Ramaze

class TCAdapterController < Template::Ramaze
  def index
    "The index"
  end
end

context "WEBrick" do
  context "multiple" do
    ramaze :mapping => {'/' => TCAdapterController}, :port => '7001..7003', :adapter => :webrick

    specify "simple request" do
      get('/').should == "The index"
    end
  end
end
