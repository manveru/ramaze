require 'spec/helper'
spec_require 'nagoro'
require 'examples/basic/element'

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
