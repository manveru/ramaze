#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TC_PagerController < Ramaze::Controller
  map '/'
  helper :pager

  def page
    stuff = [1, 2, 3, 4, 5, 6, 7, 8, 9]

    items, pager = paginate(stuff, :limit => 2)

    items.inspect
  end

end

describe "StackHelper" do
  before(:all){ ramaze }

  it "conventional login" do
    get('/page').body.should == '[1, 2]'
    get("/page", Ramaze::Pager.trait[:key] => '2').body.should == '[3, 4]'
  end
end
