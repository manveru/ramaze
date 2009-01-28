require 'spec/helper'

class MockSequelUser
  def profile
    "Arthur Dent, fearful human in outer space!"
  end

  def self.authenticate(hash)
    new if hash.values_at('name', 'password') == %w[arthur 42]
  end
end

class SpecUserHelper < Ramaze::Controller
  map '/'
  helper :user
  trait :user_model => MockSequelUser

  def status
    logged_in? ? 'yes' : 'no'
  end

  def login
    user_login
  end

  def profile
    user.profile
  end
end

describe Ramaze::Helper::User do
  behaves_like :session

  should 'login' do
    session do |mock|
      mock.get('/status').body.should == 'no'
      mock.get('/login?name=arthur&password=42')
      mock.get('/status').body.should == 'yes'
      mock.get('/profile').body.should == MockSequelUser.new.profile
    end
  end
end
