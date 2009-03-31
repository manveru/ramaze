require 'rubygems'
require 'ramaze'

# Small application performing authentication without a database

module Auth
  USERS = {
    'demo'    => Digest::SHA1.hexdigest('demo'),
    'manveru' => Digest::SHA1.hexdigest('letmein'),
  }

  class AuthController < Ramaze::Controller
    map '/', :auth
    helper :auth
    layout :auth
    trait :auth_table => USERS

    before(:secret){ login_required }
    before(:login){ redirect r('/') if logged_in? }
  end
end

Ramaze.start
