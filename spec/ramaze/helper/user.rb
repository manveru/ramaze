require 'spec/helper'

class MockSequelUser
  def profile
    "Arthur Dent, fearful human in outer space!"
  end

  def self.check(hash)
    new if hash.values_at('name', 'password') == ['arthur', '42']
  end
end

class HelperUser < Ramaze::Controller
  map '/'
  helper :user
  trait :user_model => MockSequelUser

  def status
    user.logged_in?.to_s
  end

  def login
    user.login
  end

  def profile
    user.profile
  end
end

describe Ramaze::Helper::User do
  behaves_like 'browser'
  ramaze :adapter => :webrick

  should 'login' do
    Browser.new do
      get('/status').should == 'false'
      get('/login', 'name' => 'arthur', 'password' => '42')
      get('/status').should == 'true'
      get('/profile').should == MockSequelUser.new.profile
    end
  end
end
