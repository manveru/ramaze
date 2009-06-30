require File.expand_path('../../../spec/helper', __FILE__)
require File.expand_path('../../../examples/basic/simple', __FILE__)

describe 'Simple' do
  behaves_like :rack_test

  def check(url)
    response = get(url)
    response.status.should == 200
    response.body
  end

  it '/' do
    check('/').should == 'simple'
  end

  it '/join/foo/bar' do
    check('/join/foo/bar').should == 'foobar'
  end

  it '/join/bar/baz' do
    check('/join/bar/baz').should == 'barbaz'
  end

  it '/join_all' do
    check('/join_all/a/b/c/d/e/f').should == 'abcdef'
  end

  it '/sum' do
    check('/sum/1/2').should == '3'
  end

  it '/post_or_get' do
    check('/post_or_get').should == 'GET'
  end

  it '/other' do
    check('/other').should == "Hello, World from OtherController"
  end
end
