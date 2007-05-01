require 'spec/helper'

require 'examples/hello'

context 'Hello' do
  ramaze

  specify '/' do
    get('/').should == 'Hello, World!'
  end
end
