#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'

include Ramaze

class TCControllerEzamarController < Controller
  trait :template_root => 'spec/template/ezamar'
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

context "Testing Ezamar" do
  ramaze(:mapping => {'/ezamar' => TCControllerEzamarController})

  specify "simple request to index" do
    get('/ezamar').should == 'Hello, World!'
  end

  specify "summing two values" do
    get('/ezamar/sum/1/2').should == '3'
  end

  specify "double underscore in templates" do
    get('/ezamar/some/long/action').should == 'some long action'
    get('/ezamar/another/long/action').should == 'another long action'
  end

  specify "should not respond to private methods" do
    %w[ session request response find_template handle_request trait test_private ].each do |action|
      lambda{get("/ramaze/#{action}")}.should_raise
    end
  end
end
