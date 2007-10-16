#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TCRedirectHelperController < Ramaze::Controller
  map :/

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

  def no_actual_redirect
    catch(:redirect){ redirection }
    'foo'
  end

  def no_actual_double_redirect
    catch(:redirect){ double_redirection }
    'bar'
  end
end

describe "RedirectHelper" do
  ramaze(:adapter => :mongrel)

  b = Browser.new

  it "testrun" do
    b.get('/').should == "TCRedirectHelperController"
  end

  it "should do redirection" do
    b.story do
      get('/redirection').should == "TCRedirectHelperController"
      get('/double_redirection').should == "TCRedirectHelperController"
    end
  end

  it 'should be possible to catch a redirect' do
    b.story do
      get('/no_actual_redirect').should == 'foo'
      get('/no_actual_double_redirect').should == 'bar'
    end
  end

  it "should redirect to referer" do
    b.story do
      b.get('/').should == "TCRedirectHelperController"
      get('/redirect_referer_action').should == 'TCRedirectHelperController'
      get('/noop').should == 'noop'
      get('/redirect_referer_action').should == 'noop'
    end
  end
end
