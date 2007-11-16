require 'spec/helper'
require 'examples/hello'

describe 'Hello' do
  ramaze

  it '/' do
    get('/').body.should == 'Hello, World!'
  end
end
