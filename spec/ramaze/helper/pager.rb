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

ramaze

shared 'pager' do
  behaves_like 'http'
  extend Ramaze::PagerHelper

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
    @stuff = (1..9).to_a
    @items, @pager = paginate(@stuff, :limit => 2)
  end
end

describe 'PagerHelper' do
  behaves_like 'pager'

  it 'should be paginated' do
    get('/page').body.should == [1, 2].inspect
    get('/page', pager_key => '2').body.should == [3, 4].inspect
  end

  it 'should link to other pages' do
    page = Hpricot(@pager.navigation)
    (page/:a).size.should == 6
  end
end

describe 'Pager' do
  behaves_like 'pager'

  it 'should report the number of articles as Pager#total_count' do
    @pager.total_count.should == 9
  end
end

__END__
describe "Pager", :shared => true do
  include Ramaze::PagerHelper

  it "should report the number of articles as Pager#total_count" do
    @pager.should.not be_nil
    @pager.total_count.should == 5
  end

  it "should return the same number of items as passed to :per_page" do
    @items.should.not be_nil
    @items.size.should == 2
  end

  it "should link to other pages" do
    @pager.should.not be_nil
    @pager.navigation.should.not be_nil

    require 'hpricot'
    page = Hpricot(@pager.navigation)
    (page / 'a').size.should == 4
  end

end

describe "OgPager" do
  it_should_behave_like "Pager"

  module Og; end
  module Og::Mixin; end
  module Og::Collection; end

  before do
    person = mock("Person")
    person.should_receive(:count).with(any_args).and_return(5)
    person.should_receive(:all).with(any_args).and_return([1,2])
    person.should_receive(:is_a?).any_number_of_times do |x|
      x.inspect =~ /Og::Mixin/
    end

    @items, @pager = paginate(person, :limit => 2)
  end

end

describe "OgCollectionPager" do
  it_should_behave_like "Pager"

  module Og; end
  module Og::Mixin; end
  module Og::Collection; end

  before do
    collection = mock("Og::HasMany.new")
    collection.should_receive(:count).with(any_args).and_return(5)
    collection.should_receive(:reload).with(any_args).and_return([1,2])
    collection.should_receive(:is_a?).any_number_of_times do |x|
      x.inspect =~ /Og::Collection/
    end

    @items, @pager = paginate(collection, :limit => 2)
  end

end

describe "ArrayPager" do
  it_should_behave_like "Pager"

  before do
    stuff = [1, 2, 3, 4, 5]
    @items, @pager = paginate(stuff, :limit => 2)
  end

end
