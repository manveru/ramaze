require 'spec/helper'

require 'examples/simple'

describe 'Simple' do
  ramaze

  it '/' do
    get('/').should == 'simple'
  end

  it '/simple' do
    get('/simple').should =~ /^#<Ramaze::Request/
  end

  it '/join' do
    get('/join/foo/bar').should == 'foobar'
    get('/join/bar/baz').should == 'barbaz'
  end

  it '/join_all' do
    get('/join_all/a/b/c/d/e/f').should == 'abcdef'
  end

  it '/sum' do
    get('/sum/1/2').should == '3'
  end

  it '/post_or_get' do
    get('/post_or_get').should == 'GET'
  end

  it '/other' do
    get('/other').should == "Hello, World from OtherController"
  end
end
