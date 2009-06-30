require File.expand_path('../../../spec/helper', __FILE__)
require File.expand_path('../../../examples/helpers/cache', __FILE__)

describe 'Caching' do
  behaves_like :rack_test

  it '/' do
    3.times do
      lambda{ get('/') }.should.not.change{ get('/').body }
    end

    3.times do
      lambda{ get('/invalidate') }.should.change{ get('/').body }
    end
  end
end
