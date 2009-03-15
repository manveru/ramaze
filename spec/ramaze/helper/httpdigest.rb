require 'spec/helper'

REALM = 'HttpDigestTestRealm'

class MainController < Ramaze::Controller
    
  map '/'
  helper :httpdigest

  def authenticate
    user = httpdigest('protected', REALM) do |username|
      Digest::MD5.hexdigest([username, REALM, username.reverse].join(':'))
    end
    "Hello #{user}"
  end

end

class PlainTextController < Ramaze::Controller
  map '/plaintext'
  helper :httpdigest

  def authenticate
    user = httpdigest('protected', REALM)
    "Hello #{user}"
  end

  protected

  def httpdigest_lookup_plaintext_password username
    username.reverse
  end
end

class PasswordLookupController < Ramaze::Controller
  map '/lookup'
  helper :httpdigest

  def authenticate
    user = httpdigest('protected', REALM)
    "Hello #{user}"
  end

  def httpdigest_lookup_password username
    Digest::MD5.hexdigest([username, REALM, username.reverse].join(':'))
  end
end

describe Ramaze::Helper::HttpDigest do
  behaves_like :mock, :session

  def auth_for(got, uri, username, password, qop_type = "auth")
    authorization = Rack::Auth::Digest::Params.parse(got.headers['WWW-Authenticate'])

    cnonce = Digest::MD5.hexdigest(rand.to_s)
    nc = 1
    nonce = authorization['nonce']

    authorization['cnonce'] = cnonce
    authorization['nc'] = nc
    authorization['uri'] = uri
    authorization['username'] = username
    authorization['qop'] = qop_type

    ha1 = Digest::MD5.hexdigest([username, REALM, password].join(':'))
    a2 = ['GET',uri]
    a2 << Digest::MD5.hexdigest('') if qop_type == "auth-int"
    ha2 = Digest::MD5.hexdigest( a2.join(':') )

    authorization['response'] = Digest::MD5.hexdigest([ha1, nonce, nc, cnonce, qop_type, ha2].join(':'))

    "Digest #{authorization}"
  end

  def get_auth( uri, username, password, qop_type = "auth" )
    got = nil
    session do |mock|
      got = mock.get( uri )
      got.status.should == 401
      got.body.should == 'Unauthorized'
      got = mock.get( uri , 'HTTP_AUTHORIZATION' => auth_for(got, uri, username, password, qop_type ) )
    end
    got
  end

  it 'sends out all the required header information' do
    session do |mock|
      got = mock.get('/authenticate')
      authorization = Rack::Auth::Digest::Params.parse(got.headers['WWW-Authenticate'])
      authorization["opaque"].should.not.be.empty
      authorization["nonce"].should.not.be.empty
      authorization["realm"].should == REALM
      authorization["qop"].should == "auth,auth-int"
      got = mock.get( '/authenticate' , 'HTTP_AUTHORIZATION' => auth_for(got, '/authenticate', 'foo', 'oof' ) )
      got.headers.should.satisfy do |headers|
        !headers.has_key?( "WWW-Authenticate" )
      end
    end
  end

  it 'authenticates a user with a block' do
    got = get_auth( '/authenticate', 'foo', 'oof' )
    got.status.should == 200
    got.body.should == "Hello foo"
  end

  it 'fails to authenticate an incorrect password with a block' do
    got = get_auth( '/authenticate', 'foo', 'bar' )
    got.status.should == 401
    got.body.should == "Unauthorized"
  end

  it 'authenticates a user with a block using auth for a random given' do
    got = get_auth( '/authenticate', 'foo', 'oof', 'some-random-non-existant-auth-type' )
    got.status.should == 200
    got.body.should == "Hello foo"
  end

  it 'authenticates a user with the plaintext method' do
    got = get_auth( '/plaintext/authenticate', 'foo', 'oof' )
    got.status.should == 200
    got.body.should == "Hello foo"
  end

  it 'fails to authenticate an incorrect password with the plaintext method' do
    got = get_auth( '/plaintext/authenticate', 'foo', 'bar' )
    got.status.should == 401
    got.body.should == "Unauthorized"
  end

  it 'authenticates a user with the password lookup method' do
    got = get_auth( '/lookup/authenticate', 'foo', 'oof' )
    got.status.should == 200
    got.body.should == "Hello foo"
  end

  it 'fails to authenticate an incorrect password with the password lookup method' do
    got = get_auth( '/lookup/authenticate', 'foo', 'bar' )
    got.status.should == 401
    got.body.should == "Unauthorized"
  end

  it 'authenticates a user with a block using auth-int' do
    got = get_auth( '/authenticate', 'foo', 'oof', 'auth-int' )
    got.status.should == 200
    got.body.should == "Hello foo"
  end

  it 'authenticates a user with the plaintext method using auth-int' do
    got = get_auth( '/plaintext/authenticate', 'foo', 'oof', 'auth-int' )
    got.status.should == 200
    got.body.should == "Hello foo"
  end

  it 'authenticates a user with the password lookup method using auth-int' do
    got = get_auth( '/lookup/authenticate', 'foo', 'oof', 'auth-int' )
    got.status.should == 200
    got.body.should == "Hello foo"
  end

end
