#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TCPartialHelperController < Ramaze::Controller
  helper :partial

  def index
    '<http><head><title>#{render_partial("/title")}</title></head></http>'
  end

  def title
    "Title"
  end
end


describe "PartialHelper" do
  ramaze(:mapping => {'/' => TCPartialHelperController})

  include Ramaze::LinkHelper

  it "should render partials" do
    get('/').body.should == '<http><head><title>Title</title></head></http>'
  end

end
