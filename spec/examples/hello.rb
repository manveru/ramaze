require 'spec/helper'
require 'examples/hello'

describe 'Hello' do
  extend MockHTTP
  ramaze

  it '/' do
    get('/').body.should == 'Hello, World!'
  end
end
