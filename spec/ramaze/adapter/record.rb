require 'spec/helper'

class TCRecordController < Ramaze::Controller
  map '/'

  def index
    'The index'
  end

  def foo
    'The foo'
  end
end

describe 'Adapter recording' do
  setup do
    ramaze :adapter => :webrick, :record => lambda{|request|
      request.remote_addr == '127.0.0.1'
    }

    @record = Ramaze::Record
  end

  it 'should record' do
    get('/').body.should == 'The index'
    get('/foo').body.should == 'The foo'
    @record.should have(2).requests
    @record.first.path_info.should == '/'
    @record.last.path_info.should == '/foo'
  end
end
