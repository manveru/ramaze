require 'spec/helper'

require 'examples/element'

describe 'Element' do
  ramaze

  it '/' do
    r = get('/')
    r.should include('<title>examples/element</title>')
    r.should include('<h1>Test</h1>')
    r.should include('<a href="http://something.com">something</a>')
    r.should include('Hello, World!')
  end
end
