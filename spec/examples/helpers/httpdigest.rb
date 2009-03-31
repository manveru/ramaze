require 'spec/helper'
require 'examples/helpers/httpdigest'

class MockDigestRequest
  def initialize(params)
    @params = params
  end

  def method_missing(sym)
    if @params.has_key? k = sym.to_s
      return @params[k]
    end
    super
  end

  def method
    @params['method']
  end

  def response(password)
    Rack::Auth::Digest::MD5.new(nil).send(:digest, self, password)
  end
end

describe Ramaze::Helper do
  behaves_like :session

  def auth_for(got, uri, username, password)
    challenge = got['WWW-Authenticate'].split(' ', 2).last
    params = Rack::Auth::Digest::Params.parse(challenge)
    params.merge!('cnonce' => 'nonsensenonce', 'method' => 'GET',
                  'nc' => '00000001', 'uri' => uri, 'username' => username)
    params['response'] = MockDigestRequest.new(params).response(password)

    "Digest #{params}"
  end

  it 'authorizes request for /eyes_only' do
    session do |mock|
      got = mock.get('/eyes_only')
      got.status.should == 401
      got.body.should == 'Unauthorized'

      auth = auth_for(got, '/eyes_only', 'foo', 'oof')
      got = mock.get('/eyes_only', 'HTTP_AUTHORIZATION' => auth)
      got.status.should == 200
      got.body.should == "Shhhh don't tell anyone"
    end
  end

  it 'authorizes request for /secret as admin' do
    session do |mock|
      got = mock.get('/secret')
      got.status.should == 401
      got.body.should == 'Unauthorized'

      auth = auth_for(got, '/secret', 'admin', 'secret')
      got = mock.get('/secret', 'HTTP_AUTHORIZATION' => auth)
      got.status.should == 200
      got.body.should == "Hello <em>admin</em>, welcome to SECRET world."
    end
  end

  it 'authorizes request for /secret as root' do
    session do |mock|
      got = mock.get('/secret')
      got.status.should == 401
      got.body.should == 'Unauthorized'

      auth = auth_for(got, '/secret', 'root', 'password')
      got = mock.get('/secret', 'HTTP_AUTHORIZATION' => auth)
      got.status.should == 200
      got.body.should == "Hello <em>root</em>, welcome to SECRET world."
    end
  end

  it 'authorizes request for /guest' do
    session do |mock|
      got = mock.get('/guest')
      got.status.should == 401
      got.body.should == 'Unauthorized'

      auth = auth_for(got, '/guest', 'guest', 'access')
      got = mock.get('/guest', 'HTTP_AUTHORIZATION' => auth)
      got.status.should == 200
      got.body.should == "Hello <em>guest</em>, welcome to GUEST world."
    end
  end
end
