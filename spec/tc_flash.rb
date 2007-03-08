#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'

class TCRedirectHelperController < Ramaze::Controller
  helper :flash, :redirect

  def index
    self.class.name
  end

  def noop
    'noop'
  end
  
  def set(par)
    flash[:ERROR] = par
    flash
    flash[:ERROR]
  end
  
  def set1(par)
    flash[:ERROR] = par
    flash
    redirect :get
  end
  
  def get
    flash
    flash[:ERROR]
  end
  
  def set2(par)
    flash[:ERROR] = par
    flash
    redirect :get2
  end
  
  def get2
    flash
    redirect :get
  end
  
end

context "Flash" do
  ramaze(:mapping => {'/' => TCRedirectHelperController})

  ctx = Context.new

  specify "testrun" do
    ctx.get('/').should == "TCRedirectHelperController"
  end

  specify "single redirect" do
    ctx.story do
      get('/noop').should        == "noop"
      get('/set1/success').should == 'success'
    end
  end
  
  specify "double redirect" do
    ctx.story do
      get('/set2/success').should == 'success'
    end
  end
  
  specify "on third request flash should be empty" do
    ctx.get('/set/success')
    ctx.get('/get').should == 'success'
    ctx.get('/get').empty?.should == true
  end
  
end
