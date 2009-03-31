require 'spec/helper'

class SpecHelperRequestAccessor < Ramaze::Controller
  map '/'
  helper :request_accessor

  def index
    get? ? 'GET' : request_method
  end
end

describe 'Ramaze::Helper::RequestAccessor' do
  behaves_like :mock

  it 'gives direct access to methods in Request' do
    get('/').body.should == 'GET'
    put('/').body.should == 'PUT'
  end
end
