require 'spec/helper'

class TCFileHelper < Ramaze::Controller
  map '/'

  def index
    send_file(__FILE__)
  end
end

context 'FileHelper' do
  ramaze

  specify 'serving a file' do
    get('/').should == File.read(__FILE__).strip
  end
end
