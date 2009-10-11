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

  def logout
    httpdigest_logout
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

  describe 'Digest authentication' do
    behaves_like :rack_test

    it 'authenticates a user with a block' do
      get '/logout'
      digest_authorize nil, nil

      get '/authenticate'
      last_response.status.should == 401
      last_response.body.should == "Unauthorized"

      digest_authorize 'foo', 'oof'
      get '/authenticate'
      last_response.status.should == 200
      last_response.body.should == "Hello foo"
    end

    it 'fails to authenticate an incorrect password with a block' do
      get '/logout'
      digest_authorize nil, nil

      get '/authenticate'
      last_response.status.should == 401
      last_response.body.should == "Unauthorized"

      digest_authorize 'foo', 'bar'
      get '/authenticate'
      last_response.status.should == 401
      last_response.body.should == "Unauthorized"
    end
  end

  describe 'Plaintext authentication' do
    behaves_like :rack_test

    it 'authenticates a user with the plaintext method' do
      get '/logout'
      digest_authorize nil, nil

      get '/plaintext/authenticate'
      last_response.status.should == 401
      last_response.body.should == 'Unauthorized'

      digest_authorize 'foo', 'oof'
      get '/plaintext/authenticate'
      last_response.status.should == 200
      last_response.body.should == "Hello foo"
    end

    it 'fails to authenticate an incorrect password with the plaintext method' do
      get '/logout'
      digest_authorize nil, nil

      get '/plaintext/authenticate'
      last_response.status.should == 401
      last_response.body.should == "Unauthorized"

      digest_authorize 'foo', 'bar'
      get '/plaintext/authenticate'
      last_response.status.should == 401
      last_response.body.should == "Unauthorized"
    end
  end

  describe 'Password lookup authentication' do
    behaves_like :rack_test

    it 'authenticates a user with the password lookup method' do
      get '/logout'
      digest_authorize nil, nil

      get '/lookup/authenticate'
      last_response.status.should == 401
      last_response.body.should == "Unauthorized"

      digest_authorize 'foo', 'oof'
      get '/lookup/authenticate'
      last_response.status.should == 200
      last_response.body.should == "Hello foo"
    end

    it 'fails to authenticate an incorrect password with the password lookup method' do
      get '/logout'
      digest_authorize nil, nil

      get '/lookup/authenticate'
      last_response.status.should == 401
      last_response.body.should == "Unauthorized"

      digest_authorize 'foo', 'bar'
      get '/lookup/authenticate'
      last_response.status.should == 401
      last_response.body.should == "Unauthorized"
    end
  end

end
