require 'spec/helper'

class TCFileHelper < Ramaze::Controller
  map '/'

  def index
    send_file(__FILE__)
  end
end

describe 'FileHelper' do
  ramaze

  it 'serving a file' do
    get('/').should == File.read(__FILE__).strip
  end
end
