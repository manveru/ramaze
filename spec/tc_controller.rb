#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'

include Ramaze

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

context "Testing Ramaze" do
  ramaze(:mapping => {'/ramaze' => TCControllerRamazeController})

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
