require 'spec/helper'
testcase_requires 'ruby2ruby'

Ramaze.contrib :auto_params

module AnotherController
  def another_page
    'another page'
  end

  define_method(:css/'style.css') { 'style.css' }
end

class MainController < Ramaze::Controller
  include AnotherController
  engine :None

  def search query
    query.inspect
  end

  def create name, age = '?', occupation = nil
    [name, age, occupation].compact.join(', ')
  end

  def show *args
    args.join(', ')
  end

  def add item, price = 1.0, *args
    [item, price, *args].join(', ')
  end

  def find width, height, depth
    [width, height, depth].join(', ')
  end

  define_method('page') do
    'page'
  end
end

class GetArgsTest
  def one(a, b, c) end
  def two(a, b = 1, c = nil) end
  def three(a, *args) end
end

describe 'Method#get_args' do
  it 'should return a list of arguments' do
    gat = GetArgsTest.new
    gat.method(:one).get_args.should == [[:a], [:b], [:c]]
    gat.method(:two).get_args.should == [[:a], [:b, 1], [:c, nil]]
    gat.method(:three).get_args.should == [[:a], [:"*args"]]
  end
end

describe 'Parameterized actions' do
  behaves_like 'http'
  ramaze

  it 'should pass in values from request.params' do
    get('/create/Aman/20').body.should == 'Aman, 20'
    get('/create', :name => 'Aman', :age => 20).body.should == 'Aman, 20'

    get('/create/Aman/20/Unemployed').body.should == 'Aman, 20, Unemployed'
    get('/create', :name => 'Aman', :age => 20, :occupation => 'Unemployed').body.should == 'Aman, 20, Unemployed'

    get('/create/Aman').body.should == 'Aman, ?'
    get('/create', :name => 'Aman').body.should == 'Aman, ?'
  end

  it 'should insert nil for arguments not found' do
    get('/find', :width => 10, :depth => 20).body.should == '10, , 20'
  end

  it 'should work with variable arguments' do
    get('/show/1/2/3').body.should == '1, 2, 3'

    get('/add/Shoe').body.should == 'Shoe, 1.0'
    get('/add', :item => 'Shoe').body.should == 'Shoe, 1.0'

    get('/add/Shoe/10.50/1/2/3').body.should == 'Shoe, 10.50, 1, 2, 3'
    get('/add/Shoe/11.00').body.should == 'Shoe, 11.00'
  end

  it 'should not break existing methods' do
    get('/search/Aman').body.should == '"Aman"'
    get('/search', 'query=Aman').body.should == '"Aman"'
    get('/search/tmm1', 'query=Aman').body.should == ['tmm1','Aman'].inspect
  end

  it 'should consolidate all values for the same key into an array' do
    get('/add', 'item=Shoe&item=Shirt').body.should == 'Shoe, Shirt, 1.0'
    get('/add/Pants', 'item=Shoe&item=Shirt').body.should == 'Pants, Shoe, Shirt, 1.0'
    get('/add/Shoe', :item => 'Shirt').body.should == 'Shoe, Shirt, 1.0'
  end
end if method(:puts).respond_to? :get_args

describe 'Normal behavior' do
  extend MockHTTP
  ramaze

  it 'should work with no arguments' do
    get('/page').body.should == 'page'
  end

  it 'should raise no action' do
    get('/none').body.should =~ /^No Action found/
  end

  it 'should work with included actions' do
    get('/another_page').body.should == 'another page'
  end

  it 'should work with /' do
    get('/css/style.css').body.should == 'style.css'
  end
end
