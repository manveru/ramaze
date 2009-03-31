require 'rubygems'
require 'ramaze'

REALM = 'ramaze authentication required'

class MainController < Ramaze::Controller
  helper :httpdigest

  def index
    %|
<p>#{a('eyes only', :eyes_only)}</p>
<p>#{SecretController.a('secret area', '/')}</p>
<p>#{GuestController.a('guest area', '/')} username is <em>guest</em> password is <em>access</em></p>
     |
  end

  def eyes_only
    httpdigest('eyes only', REALM) do |username|
      password = username.reverse
      Digest::MD5.hexdigest([username, REALM, password].join(':'))
    end
    "Shhhh don't tell anyone"
  end

  def logout
    httpdigest_logout
    redirect_referer
  end
end

class LoginController < Ramaze::Controller
  map '/login'
  helper :httpdigest

  def index
     @username ||= session[:username]
     @username ||= httpdigest('login area', REALM)
    "Hi there #@username!"
  end

  def login
    %|
<form action="#{Rs(:post)}" method="post">
  <input type="text" name="username" />
  <input type="password" name="password" />
  <input type="submit" />
</form>
    |
  end

  def post
    username, password = request[:username, :password]

    redirect r(:login) unless password == "entry"

    session[:username] = username
    answer(r(:index))
  end

  private

  def httpdigest_failure
    call(r(:login))
  end
end

class SecretController < Ramaze::Controller
  map '/secret'
  helper :httpdigest

  USERS = { 'admin' => 'secret', 'root' => 'password' }

  before_all do
    @username = httpdigest('secret area', REALM)
  end

  def index
    "Hello <em>#@username</em>, welcome to SECRET world."
  end

  protected

  def httpdigest_lookup_plaintext_password(username)
    USERS[ username ]
  end
end

class GuestController < Ramaze::Controller
  map '/guest'
  helper :httpdigest

  before_all do
    @username = httpdigest('guest area', REALM)
  end

  def index
    "Hello <em>#@username</em>, welcome to GUEST world."
  end

  protected

  def httpdigest_lookup_password(username)
    return "b71f15b2f6dd4834224fbe02169ed94c" if username == "guest"
  end
end

Ramaze.start
