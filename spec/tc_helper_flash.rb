#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'

class TCFlashHelperController < Ramaze::Controller
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

context "CacheHelper" do
  ramaze(:adapter => :mongrel, :mapping => {'/' => TCFlashHelperController})

  specify "set it" do
    Context.new do
      get('/first_here')
      get('/then_here').should == 'hey'
      get('/then_here').should == ''
      get('/then_here').should == ''
      get('/first_here')
      get('/then_here').should == 'hey'
      get('/then_here').should == ''
    end
  end
end
