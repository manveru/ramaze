require 'rubygems'
require 'ramaze'

REALM = 'ramaze authentication required'

class MainController < Ramaze::Controller
  def index
    %|
    <p><a href="#{R(SecretController,'/')}">secret area</a></p>
    <p><a href="#{R(GuestController,'/')}">guest area</a> password must be the same as username</p>
     | 
  end
end

class SecretController < Ramaze::Controller
  map '/secret'
  helper :aspect
  helper :httpdigest

  before_all do
    @username = httpdigest('secret area',REALM) do |username|
      { 'admin' => MD5.hexdigest("admin:#{REALM}:secret"),
        'root' => MD5.hexdigest("root:#{REALM}:access"),
      }[ username ]
    end
  end

  def index
    "Hello <em>#@username</em>, welcome to SECRET world"
  end
end

class GuestController < Ramaze::Controller
  map '/guest'
  helper :aspect
  helper :httpdigest

  before_all do
    @username = httpdigest('guest area',REALM) do |username|
      username_used = username
      MD5.hexdigest([username,REALM,username].join(':'))
    end
  end

  def index
    "Hello <em>#@username</em>, welcome to GUEST world."
  end
end

Ramaze.start
