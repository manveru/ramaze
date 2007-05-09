#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TCAspectController < Ramaze::Controller
  map '/'
  helper :aspect

  def pre_aspect() '<aspect>' end
  def post_aspect() '</aspect>' end
  def wrap_aspect() '<br />' end

  def test() 'test' end
  pre :test, :pre_aspect
  post :test, :post_aspect

  def test_pre() 'test pre' end
  pre :test_pre, :pre_aspect

  def test_post() 'test post' end
  post :test_post, :post_aspect

  def test_wrap() 'test wrap' end
  wrap :test_wrap, :wrap_aspect
end

class TCAspectAllController < Ramaze::Controller
  map '/all'
  trait :foo => :bar

  helper :aspect

  def pre_aspect() '<pre>' end
  def post_aspect() '</pre>' end

  def test_all_first() 'first' end
  def test_all_second() 'second' end

  pre :all, :pre_aspect
  post :all, :post_aspect
end

describe "Aspect" do
  ramaze(:error_page => false)

  it "shouldn't overwrite traits on inclusion" do
    TCAspectAllController.trait[:foo].should == :bar
  end

  it "pre" do
    get('/test_pre').body.should == '<aspect>test pre'
  end

  it "post" do
    get('/test_post').body.should == 'test post</aspect>'
  end

  it "pre and post" do
    get('/test').body.should == '<aspect>test</aspect>'
  end

  it "wrap" do
    get('/test_wrap').body.should == '<br />test wrap<br />'
  end

  it ":all" do
    get('/all/test_all_first').body.should == '<pre>first</pre>'
    get('/all/test_all_second').body.should == '<pre>second</pre>'
  end
end
