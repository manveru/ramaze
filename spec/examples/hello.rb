require File.expand_path('../../../spec/helper', __FILE__)
require File.expand_path('../../../examples/basic/hello', __FILE__)

describe 'Hello' do
  behaves_like :rack_test

  it 'serves the index page' do
    get('/').body.should == 'Hello, World!'
  end
end
