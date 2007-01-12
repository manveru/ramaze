#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

include Ramaze

class TCFeedHelperController < Template::Ramaze
  helper :feed

  def index
    "Index #{self.class}"
  end

  def simple
    atom =
    atom_feed do
      title "foo"
    end
    p atom
    atom.to_atom
  end
end

context "FeedHelper" do
  ramaze :mapping => {'/' => TCFeedHelperController}

  specify "testrun" do
    get('/').should == "Index TCFeedHelperController"
  end

  specify "simple feed" do
    get('/simple').should == ''
  end
end
