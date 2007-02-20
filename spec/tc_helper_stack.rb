#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'

include Ramaze

class TCStackHelperController < Controller
  helper :stack

  def index
    session.inspect
  end

  def foo
    call :login unless logged_in?
    "logged in"
  end

  def bar
    call :login unless logged_in?
    request.params.inspect
  end

  def secure
    logged_in? ? 'secret content' : 'please login'
  end

  def login
    session[:logged_in] = true
    answer
  end

  def logout
    session.clear
  end

  private

  def logged_in?
    session[:logged_in]
  end
end

context "StackHelper" do
  ramaze(:mapping => {'/' => TCStackHelperController})

  ctx = Context.new

  specify "conventional login" do
    ctx.get('/secure').should == 'please login'
    ctx.get('/login')
    ctx.get('/secure').should == 'secret content'
    ctx.get('/logout')
  end

  specify "indirect login" do
    ctx.get('/foo').should == 'logged in'
    ctx.eget('/').should == {:logged_in => true, :STACK => []}
  end

  specify "indirect login with params" do
    ctx.eget('/bar', 'x' => 'y').should == {'x' => 'y'}
    ctx.eget('/').should == {:logged_in => true, :STACK => []}
  end
end
