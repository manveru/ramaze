require 'spec/helper'
require 'examples/basic/hello'

describe 'Hello' do
  behaves_like :rack_test

  it 'serves the index page' do
    get('/').body.should == 'Hello, World!'
  end
end
