#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze'

class MainController < Ramaze::Controller
  helper :identity

  def index
    if session[:openid_identity]
      %{<h1>#{flash[:success]}</h1>
        <p>You are logged in as #{session[:openid_identity]}</p>}
    else
      openid_login_form
    end
  end
end

Ramaze::Inform.loggers.each{|l| l.log_levels << :dev }
Ramaze.start :adapter => :mongrel
