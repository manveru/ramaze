#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require File.expand_path('../../../../spec/helper', __FILE__)
spec_require 'hpricot'

module Og
  class Mock
    def initialize(*a); @a = a; end
    def all(o) @a[(o[:offset]||0),o[:limit]] end
    def count(*a) @a.size end
    alias reload all
  end
  module Mixin; end
  module Collection; end
end

class TCPagerController < Ramaze::Controller
  map '/'
  helper :pager

  def page
    stuff = [1, 2, 3, 4, 5, 6, 7, 8, 9]

    items, pager = paginate(stuff, :limit => 2)

    items.inspect
  end
end

shared 'pager' do
  behaves_like :rack_test
  extend Ramaze::Helper::Pager

  def pager_key
    Ramaze::Pager.trait[:key]
  end

  # Used internally in Pager to get parameters like: ?_page=1
  def request
    req = Object.new
    def req.params
      {Ramaze::Pager.trait[:key] => 1}
    end
    req
  end

  before do
    @items, @pager = paginate(@stuff, :limit => 2)
  end

  it 'should be paginated' do
    get('/page').body.should == [1, 2].inspect
    get('/page?_page=2').body.should == [3, 4].inspect
  end

  it "should report the number of articles as Pager#total_count" do
    @pager.total_count.should.equal 5
  end

  it "should return the same number of items as passed to :per_page" do
    @items.size.should.equal 2
  end

  it "should link to other pages" do
    # mock the action
    action = '/page'
    def action.node; TCPagerController; end
    def action.name; self; end
    Ramaze::Current.actions = [action]

    @pager.should.not.be.nil
    @pager.navigation.should.not.be.nil

    page = Hpricot(@pager.navigation)
    (page / 'a').size.should == 4
  end
end

describe "Array Pager" do
  @stuff = (1..5).to_a

  behaves_like "pager"
end

describe "OgPager" do
  @stuff = Og::Mock.new(1,2,3,4,5).extend(Og::Mixin)

  behaves_like "pager"
end

describe "OgCollectionPager" do
  @stuff = Og::Mock.new(1,2,3,4,5).extend(Og::Collection)

  behaves_like "pager"
end
