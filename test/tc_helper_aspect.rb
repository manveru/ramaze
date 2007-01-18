#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

include Ramaze

class TCAspectController < Template::Ramaze
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

class TCAspectAllController < Template::Ramaze
  helper :aspect

  def pre_aspect() '<pre>' end
  def post_aspect() '</pre>' end

  def test_all_first() 'first' end
  def test_all_second() 'second' end

  pre :all, :pre_aspect
  post :all, :post_aspect
end

context "Aspect" do
  ramaze(:mapping => {'/' => TCAspectController, '/all' => TCAspectAllController})

  specify "pre" do
    get('/test_pre').should == '<aspect>test pre'
  end

  specify "post" do
    get('/test_post').should == 'test post</aspect>'
  end

  specify "pre and post" do
    get('/test').should == '<aspect>test</aspect>'
  end

  specify "wrap" do
    get('/test_wrap').should == '<br />test wrap<br />'
  end

  specify ":all" do
    get('/all/test_all_first').should == '<pre>first</pre>'
    get('/all/test_all_second').should == '<pre>second</pre>'
  end
end
