#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'
require 'open-uri'

class TCErrorController < Ramaze::Controller
  map :/

  def index
    self.class.name
  end

  def erroring
    blah
  end
end

describe "Error" do
  ramaze :error_page => true, :public_root => 'spec/ramaze/public'

  before :all do
    require 'ramaze/dispatcher/error'
    @handle_error = Ramaze::Dispatcher::Error::HANDLE_ERROR
  end

  it 'should throw errors from rendering' do
    response = get('/erroring')
    response.status.should == 500
    regex = %r(undefined local variable or method `blah' for .*?TCErrorController)
    response.body.should =~ regex
  end

  it 'should give 404 when no action is found' do
    response = get('/foobar')
    response.status.should == 404
    response.body.should =~ %r(No Action found for `/foobar' on TCErrorController)
  end

  it "should give custom status when no action is found" do
    @handle_error.should_receive(:[]).twice.
      with(Ramaze::Error::NoAction).and_return{ [707, '/error'] }

    response = get('/illegal')
    response.status.should == 707
    response.body.should =~ %r(No Action found for `/illegal' on TCErrorController)
  end

  it "should give 404 when no controller is found" do
    Ramaze::Global.should_receive(:mapping).once.and_return{ {} }
    response = get('/illegal')
    response.status.should == 404
    response.body.should =~ %r(No Controller found for `/illegal')
  end

  it "should return custom error page" do
    @handle_error.should_receive(:[]).twice.
      with(Ramaze::Error::NoAction).and_return{ [404, '/error404'] }
    response = get('/illegal')
    response.status.should == 404
    response.body.should == '404 - not found'
  end
end
