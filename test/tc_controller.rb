#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

include Ramaze

class TCControllerAmritaController < Template::Amrita2
  def index
    "The index"
  end

  private

  def test_private
  end
end

class TCControllerRamazeController < Template::Ramaze
  def index
    "The index"
  end

  def sum first, second
    first.to_i + second.to_i
  end

  private

  def test_private
  end
end

ramaze(:mapping => {'/amrita' => TCControllerAmritaController, '/ramaze' => TCControllerRamazeController}) do
  context "Testing Ramaze" do
    specify "simple request to index" do
      get('/ramaze').should == 'The index'
    end

    specify "summing two values" do
      get('/ramaze/sum/1/2').should == '3'
    end

    specify "should not respond to private methods" do
      %w[ session request response find_template handle_request trait test_private ].each do |action|
        lambda{get("/ramaze/#{action}")}.should_raise OpenURI::HTTPError
      end
    end
  end

  context "Testing Amrita" do
    specify "simple request to index" do
      get('/amrita').should == "<div>The index</div>"
    end

    specify "should not respond to private methods" do
      accessable = TCControllerAmritaController.public_instance_methods(false).sort
      not_accessable = TCControllerAmritaController.private_instance_methods(false).sort

      accessable.each do |action|
        get("/amrita/#{action}").should_not == ''
        lambda{get("/amrita/#{action}")}.should_not_raise OpenURI::HTTPError
      end

      not_accessable.each do |action|
        lambda{get("/amrita/#{action}")}.should_raise OpenURI::HTTPError
      end

      %w[ session request response find_template handle_request trait test_private ].each do |action|
        lambda{get("/amrita/#{action}")}.should_raise OpenURI::HTTPError
      end
    end
  end
end
