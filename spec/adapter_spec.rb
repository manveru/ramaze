#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'

include Ramaze

class TCAdapterController < Controller
  def index
    "The index"
  end
end

context "Adapter" do
  ramaze ramaze_options.merge( :port => '7007..7010', :mapping => {'/' => TCAdapterController} )

  context "multiple" do
    specify "simple request" do
      get('/').should == "The index"
    end
  end
end
