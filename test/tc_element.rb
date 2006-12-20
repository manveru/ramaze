#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

include Ramaze

class TCElementController < Template::Ramaze
  def index
    "The index"
  end

  def elementy
    "<Page>#{index}</Page>"
  end
end

class Page < Ramaze::Element
  def render
    %{ <wrap> #{content} </wrap> }
  end
end

ramaze(:mapping => {'/' => TCElementController}) do
  context "Mongrel" do
    specify "simple request" do
      get('/').should == "The index"
    end

    specify "with element" do
      get('/elementy').should == "<wrap> The index </wrap>"
    end
  end
end
