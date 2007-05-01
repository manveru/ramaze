require 'spec/helper'

require 'examples/hello'

describe 'Hello' do
  ramaze

  it '/' do
    get('/').should == 'Hello, World!'
  end
end
