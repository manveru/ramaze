#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'
require 'open-uri'

class TCErrorController < Ramaze::Controller
  map :/
  trait :public => 'spec/ramaze/public'

  def index
    self.class.name
  end

  def erroring
    blah
  end
end

describe "Error" do
  ramaze :error_page => true

  describe "Throwing Error" do
    it 'erroring' do
      response = get('/erroring')
      response.status.should == 500
      regex = %r(undefined local variable or method `blah' for .*?TCErrorController)
      response.body.should =~ regex
    end
  end

  describe "No Action" do
    it 'default' do
      response = get('/foobar')
      response.status.should == 404
      response.body.should =~ %r(No Action found for `/foobar' on TCErrorController)
    end

    it "No Action custom" do
      Ramaze::Dispatcher.trait[:handle_error] = { Exception => [500, '/error'] }

      response = get('/illegal')
      response.status.should == 500
      response.body.should =~ %r(No Action found for `/illegal' on TCErrorController)
    end
  end

  it "No Controller" do
    Ramaze::Global.should_receive(:mapping).twice.and_return{ {} }
    Ramaze::Dispatcher.trait[:handle_error].should_receive(:[]).twice.
      with(Ramaze::Error::NoController).and_return{ [500, '/error'] }
    response = get('/illegal')
    response.status.should == 500
    response.body.should =~ %r(No Controller found for `/error')
  end

  it "Custom Static" do
    Ramaze::Dispatcher.trait[:handle_error].should_receive(:[]).twice.
      with(Ramaze::Error::NoAction).and_return{ [404, '/error404'] }
    response = get('/foo')
    response.status.should == 404
    response.body.should == '404 - not found'
  end
end
