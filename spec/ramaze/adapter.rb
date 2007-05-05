#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TCAdapterController < Ramaze::Controller
  def index
    "The index"
  end
end

describe "Adapter" do
  ramaze ramaze_options.merge( :port => '7007..7010', :mapping => {'/' => TCAdapterController} )

  describe "multiple" do
    it "simple request" do
      browser do
        get('/').should == "The index"
      end
    end
  end
end
