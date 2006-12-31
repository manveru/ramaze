#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

include Ramaze

class TCStackHelperController < Template::Ramaze
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

  def login
    session[:logged_in] = true
    answer
  end

  private

  def logged_in?
    session[:logged_in]
  end
end

context "StackHelper" do
  ramaze(:mapping => {'/' => TCStackHelperController})

  setup do
    @ctx = Context.new
    @ctx.eget.should == {}
  end

  specify "indirect login" do
    @ctx.get('/foo').should == 'logged in'
    @ctx.eget('/').should == {:logged_in => true, :STACK => []}
  end

  specify "indirect login with params" do
    @ctx.eget('/bar?x=y').should == {'x' => 'y'}
    @ctx.eget('/').should == {:logged_in => true, :STACK => []}
  end

  specify "indirect posting fun" do
    @ctx.epost('/bar', :x => :y)['x'].should == 'y'
  end
end
