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
