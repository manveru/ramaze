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

    specify "your illegal stuff" do
      Ramaze::Dispatcher.trait[:handle_error] = { Exception => '/error', }

      lambda{ get('/illegal') }.should_raise RuntimeError
    end
  end

  context "no controller" do
    specify "your illegal stuff" do
      Ramaze::Global.mapping = {}
      Ramaze::Dispatcher.trait[:handle_error] = { Exception => '/error', }

      lambda{ get('/illegal') }.should_raise RuntimeError
    end
  end

  context "only error page (custom)" do
    specify "custom static page" do
      Ramaze::Global.mapping = {'/' => TCErrorController }
      Ramaze::Dispatcher.trait[:handle_error] = { Exception => '/error404', }

      lambda{ get('/foo') }.should_raise RuntimeError
    end
  end
end
