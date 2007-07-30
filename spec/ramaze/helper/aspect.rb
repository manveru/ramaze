#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TCAspectController < Ramaze::Controller
  map '/'
  trait :foo => :bar
  helper :aspect
  template_root(File.dirname(__FILE__)/:template)

  def test_before() 'test before' end
  before(:test_before){ '<aspect>' }

  def test_after() 'test after' end
  after(:test_after){ '</aspect>' }

  def test_wrap() 'test wrap' end
  wrap(:test_wrap){ '<br />' }
  
  wrap(:test_template) { '<aspect>' }
end

class TCAspectAllController < Ramaze::Controller
  map '/all'

  helper :aspect
  template_root(File.dirname(__FILE__)/:template)

  def test_all_first() 'first' end
  def test_all_second() 'second' end

  before_all{ '<pre>' }
  after_all{ '</pre>' }
  
  def test_all_after() 'after' end
end

describe "AspectHelper" do
  ramaze(:error_page => false)

  it "shouldn't overwrite traits on inclusion" do
    TCAspectController.trait[:foo].should == :bar
  end

  it 'should use before' do
    get('/test_before').body.should == '<aspect>test before'
  end

  it 'should use after' do
    get('/test_after').body.should == 'test after</aspect>'
  end

  it 'should use wrap' do
    get('/test_wrap').body.should == '<br />test wrap<br />'
  end
  
  it 'should wrap templates' do
    get('/test_template').body.should == '<aspect>I am a template.<aspect>'
  end

  it 'should before_all and after_all' do
    get('/all/test_all_first').body.should == '<pre>first</pre>'
    get('/all/test_all_second').body.should == '<pre>second</pre>'
  end
  
  it 'should before_all and after_all for templates' do
    get('/all/test_template').body.should == '<pre>I am a template.</pre>'
  end
  
  it 'should before_all and after_all for all defined actions' do
    get('/all/test_all_after').body.should == '<pre>after</pre>'
  end
end
