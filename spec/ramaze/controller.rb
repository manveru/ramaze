#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TCControllerEzamarController < Ramaze::Controller
  map :/
  trait :template_root => 'spec/ramaze/template/ezamar'

  def index
    @text = "World"
  end

  def sum first, second
    @num1, @num2 = first.to_i, second.to_i
  end

  def some__long__action
  end

  def another__long__action
  end

  private

  def test_private
  end
end

describe "Controller" do
  ramaze :error_page => false

  it "simple request to index" do
    get('/').body.should == 'Hello, World!'
  end

  it "summing two values" do
    get('/sum/1/2').body.should == '3'
  end

  it "double underscore in templates" do
    get('/some/long/action').body.should == 'some long action'
    get('/another/long/action').body.should == 'another long action'
  end

  describe "should not respond to private methods" do
    TCControllerEzamarController.private_methods.sort.each do |action|
      next if action =~ /\?$/ or action == '`'
      it action do
        path = "/#{action}"
        response = get(path)
        response.body.should_not =~ %r(<title>No Action found for `' on Class</title>)
        message = "No Action found for `#{path}' on TCControllerEzamarController"
        response.body.should =~ %r(<title>#{message}</title>)
        response.status.should == 404
      end
    end
  end
end
