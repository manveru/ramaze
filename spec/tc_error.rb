#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'
require 'open-uri'

class TCErrorController < Ramaze::Controller
  trait :public => 'spec/public'

  def index
    self.class.name
  end
end

context "Error" do
  context "in dispatcher" do
    ramaze :mapping => {'/' => TCErrorController }, :error_page => true
    Ramaze::Dispatcher.trait[:handle_error] = { Exception => '/error', }

    specify "your illegal stuff" do
      get('/def/illegal').should == '404 - not found'
    end
  end

  context "no controller" do
    Ramaze::Global.mapping = {}
    Ramaze::Dispatcher.trait[:handle_error] = { Exception => '/error', }

    specify "your illegal stuff" do
      get('/def/illegal').should == '404 - not found'
    end
  end

  context "only error page (custom)" do
    Ramaze::Global.mapping = {'/' => TCErrorController }
    Ramaze::Dispatcher.trait[:handle_error] = { Exception => '/error404', }

    get('/foo').should == '404 - not found'
  end
end
