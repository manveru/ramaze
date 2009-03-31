#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class SpecStackHelper < Ramaze::Controller
  map '/'
  helper :stack
  engine :None

  def logged_in_page
    call(r(:login)) unless logged_in?
    "the logged in page"
  end

  def logged_in_params
    call(r(:login)) unless logged_in?
    request.params.inspect
  end

  def secure
    logged_in? ? 'secret content' : 'please login'
  end

  def login
    session[:logged_in] = true
    answer(r(:secure))
  end

  def logout
    session.delete(:logged_in)
  end

  private

  def logged_in?
    session[:logged_in]
  end
end

describe Ramaze::Helper::Stack do
  behaves_like :session
  @uri = 'http://example.org'

  should 'login directly' do
    session do |mock|
      mock.get('/secure').body.should == 'please login'

      got = mock.get('/login')
      got.status.should == 302
      got['Location'].should == "#@uri/secure"

      got = mock.get('/secure')
      got.status.should == 200
      got.body.should == 'secret content'

      mock.get('/secure').body.should == 'secret content'
      mock.get('/logout')
      mock.get('/secure').body.should == 'please login'
    end
  end

  should 'login via redirects' do
    session do |mock|
      got = mock.get('/logged_in_page')
      got.status.should == 302
      got['Location'].should == 'http://example.org/login'

      got = mock.get('/login')
      got.status.should == 302
      got['Location'].should == 'http://example.org/logged_in_page'

      got = mock.get('/logged_in_page')
      got.status.should == 200
      got.body.should == 'the logged in page'
    end
  end

  should 'login with params via redirects' do
    session do |mock|
      got = mock.get('/logged_in_params?x=y')
      got.status.should == 302
      got['Location'].should == 'http://example.org/login'

      got = mock.get('/login')
      got.status.should == 302
      got['Location'].should == 'http://example.org/logged_in_params?x=y'

      got = mock.get('/logged_in_params?x=y')
      got.status.should == 200
      got.body.should == {'x' => 'y'}.inspect
    end
  end
end
