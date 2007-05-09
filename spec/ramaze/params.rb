#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TCParamsController < Ramaze::Controller
  def index
    "index"
  end

  def no_params
    "no params"
  end

  def single_param param
    "single param (#{param})"
  end

  def double_param param1, param2
    "double param (#{param1}, #{param2})"
  end

  def all_params *params
    "all params (#{params.join(', ')})"
  end

  def at_least_one param, *params
    "at least one (#{param}, #{params.join(', ')})"
  end

  def one_default param = 'default'
    "one_default (#{param})"
  end

  def cat1__cat11
    'cat1: cat11'
  end

  def cat1__cat11__cat111
    'cat1: cat11: cat111'
  end
end

class TCParamsController2 < Ramaze::Controller
  def add(one, two = nil, three = nil)
    "#{one}:#{two}:#{three}"
  end
end

describe "Simple Parameters" do
  ramaze(
    :mapping => {
        '/' => TCParamsController,
        '/jo' => TCParamsController2
      }
  )

  it "Should respond to no parameters given" do
    get('/no_params').body.should == "no params"
  end

  it "Should respond to only / with the index" do
    get('/').body.should == "index"
  end

  it "call /bar though index doesn't take params" do
    get('/bar').status.should == 404
  end

  it "action that takes a single param" do
    get('/single_param/foo').body.should == "single param (foo)"
  end

  it "action that takes two params" do
    get('/double_param/foo/bar').body.should == "double param (foo, bar)"
  end

  it "action that takes two params but we give only one" do
    get('/double_param/foo').status.should == 404
  end

  it "action that takes all params" do
    get('/all_params/foo/bar/foobar').body.should == "all params (foo, bar, foobar)"
  end

  it "action that takes all params but needs at least one" do
    get('/at_least_one/foo/bar/foobar').body.should == "at least one (foo, bar, foobar)"
  end

  it "action that takes all params but needs at least one (not given here)" do
    get('/at_least_one').status.should == 404
  end

  it "one default" do
    get('/one_default').body.should == "one_default (default)"
  end

  it "one default" do
    get('/one_default/my_default').body.should == "one_default (my_default)"
  end

  it "double underscore lookup" do
    get('/cat1/cat11').body.should == 'cat1: cat11'
  end

  it "double double underscore lookup" do
    get('/cat1/cat11/cat111').body.should == 'cat1: cat11: cat111'
  end


  it "jo/add should raise with 0 parameters" do
    get('/jo/add').status.should == 404
  end

  it "add should raise with 4 parameters" do
    get('/jo/add/1/2/3/4').status.should == 404
  end

  it "add should not raise with 1-3 parameters" do
    get('/jo/add/1').body.should == '1::'
    get('/jo/add/1/2').body.should == '1:2:'
    get('/jo/add/1/2/3').body.should == '1:2:3'
  end
end
