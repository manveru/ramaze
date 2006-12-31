#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

include Ramaze

class TCAdapterController < Template::Ramaze
  def index
    "The index"
  end
end

context "Mongrel" do
  ramaze(:mapping => {'/' => TCAdapterController}, :adapter => :mongrel)

  specify "simple request" do
    get('/').should == "The index"
  end
end
