# (c) 2009 Mickael Riga
#
# A very simple example of how to authenticate imap users
# You may want to do that in order to open an app to all imap users of the same domain
# 
# IMPORTANT:
# Don't forget to add some SSL magic
# 
require 'rubygems'
require 'ramaze'

require 'net/imap'

class MainController < Ramaze::Controller
  
  helper :aspect
  
  before_all do
    if session[:login].nil? and !action.path[/^\/log(in|out)$/]
      session[:initial_request] ||= request.path_info
      redirect '/login' 
    end
  end
  
  def index
    "Here is a big secret that only IMAP users can see."
  end
  
  # ===================
  # = Login functions =
  # ===================
  
  def login
    if request.post? and imap_user?(request[:login], request[:pass])
      session[:login] = request[:login].gsub(/@example\.com$/, '')
      redirect session[:initial_request]
    end
    %{
      <form action="/login" method="post">
      Login<br />
      	<input type='text' value='' name='login' /><br /><br />
      	Password<br />
      	<input type='password' value='' name='pass' /><br /><br />
      	<input class="button go" name="commit" title="Submit Login" type="submit" value="Login" />
      </form>
    }
  end
  def logout
    session.clear
    "You're now logged-out."
  end
  
  private
  
  # ====================================
  # = Verify login via imap connection =
  # ====================================
  
  def imap_user?(login, pass)
    # Allow people to use only their login without domain part
    login += '@example.com' unless login[/@example\.com$/]
    # Replace by the name of your imap server
    imap = Net::IMAP::new('example.com')
    return imap.login(login,pass)
  rescue
    false
  ensure
    imap.disconnect
  end
end

Ramaze.start