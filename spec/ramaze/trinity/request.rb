require 'spec/helper'

describe 'Ramaze::Request' do
  def request(env = {})
    Ramaze::Request.new(env)
  end

  it 'should show request_uri' do
    request('REQUEST_URI' => '/?a=b').request_uri.should == '/?a=b'
    request(  'PATH_INFO' => '/'    ).request_uri.should == '/'
  end

  it 'should show local_net?' do
    request.local_net?('192.168.0.1').to_s.should == '192.168.0.0'
    request.local_net?('252.168.0.1').should be_nil
    request.local_net?('unknown').should be_nil
    request('REMOTE_ADDR' => '211.3.129.47, 66.249.85.131').local_net?.should be_nil
    request('REMOTE_ADDR' => '211.3.129.47').local_net?.should be_nil
  end
end
