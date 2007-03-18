#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'

class TCRedirectHelperController < Ramaze::Controller
  helper :redirect

  def index
    self.class.name
  end

  def noop
    'noop'
  end

  def redirection
    redirect R(:index)
  end

  def double_redirection
    redirect R(:redirection)
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
    ctx.story do
      get('/redirection').should        == "TCRedirectHelperController"
      get('/double_redirection').should == "TCRedirectHelperController"
    end
  end

  specify "redirect to referer" do
    ctx.story do
      get('/redirect_referer_action').should == 'TCRedirectHelperController'
      get('/noop').should                    == 'noop'
      get('/redirect_referer_action').should == 'noop'
    end
  end
end
