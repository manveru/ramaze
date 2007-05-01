#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'
require 'open-uri'

class TCErrorController < Ramaze::Controller
  trait :public => 'spec/public'

  def index
    self.class.name
  end
end

describe "Error" do
  describe "in dispatcher" do
    ramaze :mapping => {'/' => TCErrorController }, :error_page => true

    it "your illegal stuff" do
      Ramaze::Dispatcher.trait[:handle_error] = { Exception => '/error', }

      lambda{ get('/illegal') }.should raise_error(RuntimeError)
    end
  end

  describe "no controller" do
    it "your illegal stuff" do
      Ramaze::Global.mapping = {}
      Ramaze::Dispatcher.trait[:handle_error] = { Exception => '/error', }

      lambda{ get('/illegal') }.should raise_error(RuntimeError)
    end
  end

  describe "error page" do
    it "custom static" do
      Ramaze::Global.mapping = {'/' => TCErrorController }
      Ramaze::Dispatcher.trait[:handle_error] = { Exception => '/error404', }

      lambda{ get('/foo') }.should raise_error(RuntimeError)
    end
  end
end
