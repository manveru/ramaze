#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require File.expand_path('../../../../spec/helper', __FILE__)

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

  def httpdigest_lookup_plaintext_password(username)
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

  protected

  def httpdigest_lookup_password username
    Digest::MD5.hexdigest([username, REALM, username.reverse].join(':'))
  end
end

describe Ramaze::Helper::HttpDigest do
  describe 'headers' do
    behaves_like :rack_test

    it 'sends out all the required header information' do
      get '/authenticate'
      www_authenticate = last_response.headers['WWW-Authenticate']
      authorization = Rack::Auth::Digest::Params.parse(www_authenticate)
      authorization["opaque"].should.not.be.empty
      authorization["nonce"].should.not.be.empty
      authorization["realm"].should == REALM
      authorization["qop"].should == "auth,auth-int"

      digest_authorize 'foo', 'oof'
      get '/authenticate'
      last_response.headers.should.satisfy do |headers|
        !headers.has_key?( "WWW-Authenticate" )
      end
    end
  end
end

__END__

  describe 'Digest authentication' do
    behaves_like :rack_test

    it 'authenticates a user with a block' do
      digest_authorize 'foo', 'oof'
      get '/authenticate'
      last_response.status.should == 200
      last_response.body.should == "Hello foo"
    end

    it 'fails to authenticate an incorrect password with a block' do
      digest_authorize 'foo', 'bar'
      get '/authenticate'
      last_response.status.should == 401
      last_response.body.should == "Unauthorized"
    end
  end

  describe 'Plaintext authentication' do
    behaves_like :rack_test

    it 'authenticates a user with the plaintext method' do
      get '/plaintext/authenticate'
      last_response.status.should == 401
      last_response.body.should == 'Unauthorized'

      authorize 'foo', 'oof'
      get '/plaintext/authenticate'
      last_response.status.should == 200
      last_response.body.should == "Hello foo"
    end

    it 'fails to authenticate an incorrect password with the plaintext method' do
      authorize 'foo', 'bar'
      get '/plaintext/authenticate'
      last_response.status.should == 401
      last_response.body.should == "Unauthorized"
    end
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
