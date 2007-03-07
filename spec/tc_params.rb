#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'

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

context "Simple Parameters" do
  ramaze(
    :mapping => {
        '/' => TCParamsController,
        '/jo' => TCParamsController2
      }
  )

  specify "Should respond to no parameters given" do
    get('/no_params').should == "no params"
  end

  specify "Should respond to only / with the index" do
    get('/').should == "index"
  end

  specify "call /bar though index doesn't take params" do
    lambda{ get('/bar') }.should_raise #OpenURI::HTTPError
  end

  specify "action that takes a single param" do
    get('/single_param/foo').should == "single param (foo)"
  end

  specify "action that takes two params" do
    get('/double_param/foo/bar').should == "double param (foo, bar)"
  end

  specify "action that takes two params but we give only one" do
    lambda{ get('/double_param/foo') }.should_raise #OpenURI::HTTPError
  end

  specify "action that takes all params" do
    get('/all_params/foo/bar/foobar').should == "all params (foo, bar, foobar)"
  end

  specify "action that takes all params but needs at least one" do
    get('at_least_one/foo/bar/foobar').should == "at least one (foo, bar, foobar)"
  end

  specify "action that takes all params but needs at least one (not given here)" do
    lambda{ get('/at_least_one') }.should_raise #OpenURI::HTTPError
  end

  specify "one default" do
    get('/one_default').should == "one_default (default)"
  end

  specify "one default" do
    get('/one_default/my_default').should == "one_default (my_default)"
  end

  specify "double underscore lookup" do
    get('/cat1/cat11').should == 'cat1: cat11'
  end

  specify "double double underscore lookup" do
    get('/cat1/cat11/cat111').should == 'cat1: cat11: cat111'
  end


  specify "jo/add should raise with 0 parameters" do
    lambda{ get('/jo/add') }.should_raise
  end
  
  specify "add should raise with 4 parameters" do
    lambda{ get('/jo/add/1/2/3/4') }.should_raise
  end
  
  specify "add should not raise with 1-3 parameters" do
    get('/jo/add/1').should == '1::'
    get('/jo/add/1/2').should == '1:2:'
    get('/jo/add/1/2/3').should == '1:2:3'
  end
  
end
