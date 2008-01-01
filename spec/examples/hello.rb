require 'spec/helper'
require 'examples/hello'

describe 'Hello' do
  behaves_like 'http'
  ramaze

  it '/' do
    get('/').body.should == 'Hello, World!'
  end
end
