#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

include Ramaze

class MainController < Template::Ramaze
  def index
    "The index"
  end
end

ramaze(:adapter => :mongrel) do
  context "Mongrel" do
    specify "simple request" do
      get('/').should == "The index"
    end
  end
end

ramaze(:adapter => :webrick) do
  context "WEBrick" do
    specify "simple request" do
      get('/').should == "The index"
    end
  end
end
