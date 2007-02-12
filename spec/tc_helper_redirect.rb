#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'

include Ramaze

class TCRedirectHelperController < Template::Ezamar
  helper :redirect

  def index
    self.class.name
  end

  def noop
    'noop'
  end

  def redirection
    redirect :index
  end

  def double_redirection
    redirect :redirection
  end

  def redirect_referer_action
    redirect_referer
  end
end

context "RedirectHelper" do
  ramaze(:mapping => {'/' => TCRedirectHelperController})

  ctx = Context.new

  specify "testrun" do
    ctx.get('/').should == "TCRedirectHelperController"
  end

  specify "calls" do
    ctx.get('/redirection').should        == "TCRedirectHelperController"
    ctx.get('/double_redirection').should == "TCRedirectHelperController"
  end

  specify "redirect to referer" do
    ctx.get('/redirect_referer_action').should == 'TCRedirectHelperController'
    ctx.get('/noop').should                    == 'noop'
    ctx.get('/redirect_referer_action').should == 'noop'
  end
end
