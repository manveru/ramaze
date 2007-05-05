#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TCFlashHelperFirstController < Ramaze::Controller
  map :/
  helper :flash

  def index
    self.class.name
  end

  def first_here
    flash[:first] = 'hey'
  end

  def then_here
    flash[:first].to_s
  end
end

class TCFlashHelperSecondController < Ramaze::Controller
  map '/second'
  helper :flash

  def index
    self.class.name
  end

  def first_here
    flash[:first] = 'hey'
  end

  def then_here
    flash[:first].to_s
  end
end

class TCFlashHelperThirdController < Ramaze::Controller
  map '/third'
  helper :flash

  def index
  end

  def noop
    'noop'
  end
  
  def set par
    flash[:e] = par
  end

  def retrieve
    flash[:e]
  end
end

describe "FlashHelper" do
  ramaze :adapter => :webrick

  it "twice" do
    browser '/' do
      get('/first_here')
      get('/then_here').should == 'hey'
      get('/then_here').should == ''
      get('/then_here').should == ''
      get('/first_here')
      get('/then_here').should == 'hey'
      get('/then_here').should == ''
    end
  end

  it "over seperate controllers" do
    browser do
      get('/first_here')
      get('/second/then_here').should == 'hey'
      get('/then_here').should == ''
      get('/second/then_here').should == ''
      get('/second/first_here')
      get('/then_here').should == 'hey'
      get('/second/then_here').should == ''
    end
  end

  it "single" do
    browser do
      get('/third/set/foo').should == 'foo'
    end
  end
  
  it "single" do
    browser do
      get('/third/set/foo').should == 'foo'
      get('/third/retrieve').should == 'foo'
      get('/third/retrieve').should == ''
      get('/third/retrieve').should == ''
    end
  end
end
