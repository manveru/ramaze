require File.expand_path('../../../spec/helper', __FILE__)
spec_require 'nagoro'
require File.expand_path('../../../examples/basic/element', __FILE__)

describe 'Element' do
  behaves_like :rack_test

  it '/' do
    r = get('/').body
    r.should.include('<title>examples/element</title>')
    r.should.include('<h1>Test</h1>')
    r.should.include('<a href="http://something.com">something</a>')
    r.should.include('Hello, World!')
  end
end
