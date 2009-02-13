#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

$password = Digest::SHA1.hexdigest('pass')

class SpecHelperAuth < Ramaze::Controller
  map '/'
  helper :auth

  def index
    self.class.name
  end

  def session_inspect
    session.inspect
  end

  def secured
    "Secret content"
  end
  before(:secured){ login_required }
end

class SpecHelperAuthHash < SpecHelperAuth
  map '/hash'
  trait :auth_table => {
      'manveru' => $password
    }
end

class SpecHelperAuthMethod < SpecHelperAuth
  map '/method'
  trait :auth_table => :auth_table

  def auth_table
    { 'manveru' => $password }
  end
end

class SpecHelperAuthLambda < SpecHelperAuth
  map '/lambda'
  trait :auth_table => lambda{
      { 'manveru' => $password }
    }
end

describe Ramaze::Helper::Auth do
  behaves_like :session

  def multipart_env(hash)
    boundary = 'MuLtIpArT56789'
    data = []
    hash.each do |key, value|
      data << "--#{boundary}"
      data << %(Content-Disposition: form-data; name="#{key}")
      data << ''
      data << value
    end
    data << "--#{boundary}--"
    body = data.join("\r\n")

    type = "multipart/form-data; boundary=#{boundary}"
    length = body.respond_to?(:bytesize) ? body.bytesize : body.size

    { 'CONTENT_TYPE' => type,
      'CONTENT_LENGTH' => length.to_s,
      :input => StringIO.new(body) }
  end

  def procedure(prefix)
    session do |mock|
      got = mock.get("#{prefix}/secured")
      got.status.should == 302
      got['Location'].should =~ (/#{prefix}\/login$/)

      got = mock.get("#{prefix}/login")
      got.status.should == 200
      got.body.should =~ (/<form/)

      env = multipart_env('username' => 'manveru', 'password' => 'pass')
      got = mock.post("#{prefix}/login", env)
      got.status.should == 302
      got['Location'].should =~ (/#{prefix}\/secured/)

      got = mock.get("#{prefix}/secured")
      got.status.should == 200
      got.body.should == 'Secret content'

      got = mock.get("#{prefix}/logout")
      got.status.should == 302
      got['Location'].should =~ (/\/$/)

      got = mock.get("#{prefix}/secured")
      got.status.should == 302
      got['Location'].should =~ (/#{prefix}\/login$/)
    end
  end

  it 'authenticates by looking into a hash' do
    procedure('/hash')
  end

  it 'authenticates by looking into a lambda' do
    procedure('/lambda')
  end

  it 'authenticates by looking into a method' do
    procedure('/method')
  end
end
