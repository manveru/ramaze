#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TCAspectController < Ramaze::Controller
  map '/'
  trait :foo => :bar
  helper :aspect

  def test_before() request[:before] += 2 end
  before(:test_before){ request[:before] = 40 }

  def test_after() request[:after] = 40 end
  after(:test_after){ request[:after] += 2 }

  def test_wrap() end
  wrap(:test_wrap){ request[:wrap] ||= 0; request[:wrap] += 21 }

  wrap(:test_template) { '<aspect>' }
end

class TCAspectAllController < Ramaze::Controller
  map '/all'

  helper :aspect
  view_root __DIR__/:view

  def test_all_first() 'first' end
  def test_all_second() 'second' end

  before_all{ request[:all] = 40 }
  after_all{ request[:all] += 2 }

  def test_all_after() 'after' end

  def layout() '<div>#@content</div>' end
  template :loop_with_layout, :loop
  layout :layout => [:loop_with_layout]
end

describe "AspectHelper" do
  behaves_like 'http'
  ramaze :error_page => false
  extend Ramaze::Trinity

  it "shouldn't overwrite traits on inclusion" do
    TCAspectController.trait[:foo].should == :bar
  end

  it 'should use before' do
    get('/test_before')
    request[:before].should == 42
  end

  it 'should use after' do
    get('/test_after')
    request[:after].should == 42
  end

  it 'should use wrap' do
    get('/test_wrap')
    request[:wrap].should == 42
  end

  it 'should before_all and after_all' do
    get('/all/test_all_first')
    request[:all].should == 42
    get('/all/test_all_second')
    request[:all].should == 42
  end

  it 'should before_all and after_all for templates' do
    get('/all/test_template')
    request[:all].should == 42
  end

  it 'should before_all and after_all for all defined actions' do
    get('/all/test_all_after')
    request[:all].should == 42
  end

  it 'should not apply aspects to render_template' do
    get('/all/loop').body.gsub(/\s/,'').should == '12345'
    request[:all].should == 42
  end

  it 'should not apply aspects to layouts' do
    get('/all/loop_with_layout').body.gsub(/\s/,'').should == '<div>12345</div>'
    request[:all].should == 42
  end
end
