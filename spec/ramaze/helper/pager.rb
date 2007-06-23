#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

testcase_requires 'hpricot'

class TCPagerController < Ramaze::Controller
  map '/'
  helper :pager

  def page
    stuff = [1, 2, 3, 4, 5, 6, 7, 8, 9]

    items, pager = paginate(stuff, :limit => 2)

    items.inspect
  end

end

describe "PagerHelper" do
  include Ramaze::PagerHelper

  before(:all){ ramaze }

  # Used internally in Pager to get parameters like: ?_page=1

  def request
    req = mock("Request")
    req.should_receive(:params).with(no_args).
                                once.
                                and_return(Ramaze::Pager.trait[:key] => 1)
    req
  end

  it "should be paginated" do
    get('/page').body.should == '[1, 2]'
    get("/page", Ramaze::Pager.trait[:key] => '2').body.should == '[3, 4]'
  end

  it "should link to other pages" do
    stuff = [1, 2, 3, 4, 5, 6, 7, 8, 9]

    items, pager = paginate(stuff, :limit => 2)
    page = Hpricot(pager.navigation)
    (page / 'a').size.should == 6
  end

end
