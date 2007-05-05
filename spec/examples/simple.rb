require 'spec/helper'

require 'examples/simple'

describe 'Simple' do
  ramaze

  after :each do
    @response.status.should == 200
  end

  it '/' do
    @response = get('/')
    @response.body.should == 'simple'
  end

  it '/simple' do
    @response = get('/simple')
    @response.body.should =~ /^#<Rack::Request/
  end

  it '/join/foo/bar' do
    @response = get('/join/foo/bar')
    @response.body.should == 'foobar'
  end

  it '/join/bar/baz' do
    @response = get('/join/bar/baz')
    @response.body.should == 'barbaz'
  end

  it '/join_all' do
    @response = get('/join_all/a/b/c/d/e/f')
    @response.body.should == 'abcdef'
  end

  it '/sum' do
    @response = get('/sum/1/2')
    @response.body.should == '3'
  end

  it '/post_or_get' do
    @response = get('/post_or_get')
    @response.body.should == 'GET'
  end

  it '/other' do
    @response = get('/other')
    @response.body.should == "Hello, World from OtherController"
  end
end
