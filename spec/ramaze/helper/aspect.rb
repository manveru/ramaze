#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TCAspectController < Ramaze::Controller
  map '/'
  trait :foo => :bar
  helper :aspect

  def test_before() 'test before' end
  before(:test_before){ '<aspect>' }

  def test_after() 'test after' end
  after(:test_after){ '</aspect>' }

  def test_wrap() 'test wrap' end
  wrap(:test_wrap){ '<br />' }
end

class TCAspectAllController < Ramaze::Controller
  map '/all'

  helper :aspect

  def test_all_first() 'first' end
  def test_all_second() 'second' end

  before_all{ '<pre>' }
  after_all{ '</pre>' }
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

  it 'should before_all and after_all' do
    get('/all/test_all_first').body.should == '<pre>first</pre>'
    get('/all/test_all_second').body.should == '<pre>second</pre>'
  end
end

=begin
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
=end
