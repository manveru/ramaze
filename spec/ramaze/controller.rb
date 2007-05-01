#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TCControllerEzamarController < Ramaze::Controller
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

describe "Testing Ezamar" do
  ramaze(:mapping => {'/ezamar' => TCControllerEzamarController})

  it "simple request to index" do
    get('/ezamar').should == 'Hello, World!'
  end

  it "summing two values" do
    get('/ezamar/sum/1/2').should == '3'
  end

  it "double underscore in templates" do
    get('/ezamar/some/long/action').should == 'some long action'
    get('/ezamar/another/long/action').should == 'another long action'
  end

  it "should not respond to private methods" do
    %w[ session request response find_template handle_request trait test_private ].each do |action|
      lambda{get("/ramaze/#{action}")}.should raise_error
    end
  end
end
