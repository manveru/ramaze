#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

include Ramaze

class TCRedirectHelperController < Template::Ramaze
  helper :redirect

  def index
    self.class.name
  end

  def redirection
    redirect :index
  end

  def double_redirection
    redirect :redirection
  end
end

context "RedirectHelper" do
  ramaze(:mapping => {'/' => TCRedirectHelperController})
  specify "testrun" do
    get('/').should      == "TCRedirectHelperController"
  end

  specify "calls" do
    get('/redirection').should              == "TCRedirectHelperController"
    get('/double_redirection').should       == "TCRedirectHelperController"
  end
end
