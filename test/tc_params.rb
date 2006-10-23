require 'ramaze'
require 'test/test_helper'

include Ramaze

class TCParamsController < Ramaze::Template::Ramaze
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
end

context "Simple Parameters" do

  start
  Global.mapping['/'] = TCParamsController

  def request opt
    open("http://localhost:#{Ramaze::Global.port}/#{opt}").read
  end

  specify "Should respond to no parameters given" do
    request('/no_params').should_equal "no params"
  end

  specify "Should respond to only / with the index" do
    request('/').should_equal "index"
  end

  specify "call /bar though index doesn't take params" do
    lambda{(request('/bar'))}.should_raise EOFError
  end

  specify "action that takes a single param" do
    request('/single_param/foo').should_equal "single param (foo)"
  end

  specify "action that takes two params" do
    request('/double_param/foo/bar').should_equal "double param (foo, bar)"
  end

  specify "action that takes two params but we give only one" do
    lambda{(request('/double_param/foo'))}.should_raise EOFError
  end

  specify "action that takes all params" do
    request('/all_params/foo/bar/foobar').should_equal "all params (foo, bar, foobar)"
  end

  specify "action that takes all params but needs at least one" do
    request('/at_least_one/foo/bar/foobar').should_equal "at least one (foo, bar, foobar)"
  end

  specify "action that takes all params but needs at least one (not given here)" do
    lambda{(request('/at_least_one'))}.should_raise EOFError
  end

  specify "one default" do
    request('/one_default').should_equal "one_default (default)"
  end

  specify "one default" do
    (request('/one_default/my_default')).should_equal "one_default (my_default)"
  end
end
