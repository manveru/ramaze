require 'spec/helper'
require 'examples/caching'

describe 'Caching' do
  extend MockHTTP
  ramaze

  it '/' do
    3.times do
      lambda{ get('/') }.
        should.not.change{ get('/').body }
    end

    3.times do
      lambda{ get('/invalidate') }.
        should.change{ get('/').body }
    end
  end
end
