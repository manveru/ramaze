require 'spec/helper'

require 'examples/simple'

context 'Simple' do
  ramaze

  specify '/' do
    get('/').should == 'simple'
  end

  specify '/simple' do
    get('/simple').should =~ /^#<Ramaze::Request/
  end

  specify '/join' do
    get('/join/foo/bar').should == 'foobar'
    get('/join/bar/baz').should == 'barbaz'
  end

  specify '/join_all' do
    get('/join_all/a/b/c/d/e/f').should == 'abcdef'
  end

  specify '/sum' do
    get('/sum/1/2').should == '3'
  end

  specify '/post_or_get' do
    get('/post_or_get').should == 'GET'
  end

  specify '/other' do
    get('/other').should == "Hello, World from OtherController"
  end
end
