#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'
require 'open-uri'

class TCErrorController < Ramaze::Controller
  trait :public => 'spec/ramaze/public'

  def index
    self.class.name
  end
end

describe "Error" do
  describe "in dispatcher" do
    ramaze :mapping => {'/' => TCErrorController }, :error_page => true

    it "your illegal stuff" do
      Ramaze::Dispatcher.trait[:handle_error] = { Exception => [404, '/error'] }

      response = get('/illegal')
      response.status.should == 404
      response.body.should_not be_empty
      #response.body.should =~ %r(<title>No Action found for `/illegal' on TCErrorController</title>)
    end
  end

  describe "no controller" do
    it "your illegal stuff" do
      Ramaze::Global.mapping = {}
      Ramaze::Dispatcher.trait[:handle_error] = { Exception => [500, '/error'] }

      response = get('/illegal')
      response.status.should == 500
      #response.body.should =~ %r(No Controller found for `/illegal')
    end
  end

  describe "error page" do
    it "custom static" do
      Ramaze::Global.mapping = {'/' => TCErrorController }
      Ramaze::Dispatcher.trait[:handle_error] = { Exception => [404, '/error404'] }

      response = get('/foo')
      response.status.should == 404
      response.body.should == '404 - not found'
    end
  end
end
