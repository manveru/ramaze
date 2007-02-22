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

  specify "conventional login" do
    Context.new do
      get('/secure').should == 'please login'
      get('/login')
      get('/secure').should == 'secret content'
      get('/logout')
    end
  end

  specify "indirect login" do
    Context.new do
      get('/foo').should == 'logged in'
      eget('/').should == {:logged_in => true, :STACK => []}
    end
  end

  specify "indirect login with params" do
    Context.new do
      eget('/bar', 'x' => 'y').should == {'x' => 'y'}
      eget('/').should == {:logged_in => true, :STACK => []}
    end
  end
end
