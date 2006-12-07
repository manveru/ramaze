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
    call :login unless session[:logged_in]
    "logged in"
  end
  
  def bar
    call :login unless session[:logged_in]
    request.params['x']
  end

  def login
    session[:logged_in] = true
    answer
  end
end

ramaze(:mapping => {'/' => TCStackHelperController}) do
  context "StackHelper" do

    setup do
      @ctx = Context.new
      @ctx.request.should == '{}'
    end

    specify "indirect login" do
      @ctx.request('/foo').should == 'logged in'
    end

    specify "indirect login with params" do
      @ctx.request('/bar?x=y').should == 'y'
    end
  end
end
