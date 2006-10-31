require 'ramaze'
require 'test/test_helper'

include Ramaze

class AmritaController < Template::Amrita2
  def index
    "The index"
  end
end

class RamazeController < Template::Ramaze
  def index
    "The index"
  end
end

start
sleep 0.5

context "Testing Ramaze" do
  def request opt
    open("http://localhost:#{Ramaze::Global.port}/ramaze/#{opt}").read
  end

  specify "simple request should_equal" do
    request('/').should_equal "The index"
  end
end

context "Testing Amrita" do
  def request opt
    open("http://localhost:#{Ramaze::Global.port}/amrita/#{opt}").read
  end

  specify "simple request to index" do
    request('/').should_equal "The index"
  end
end
