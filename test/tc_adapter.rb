require 'ramaze'
require 'test/test_helper'

include Ramaze

class MainController < Template::Ramaze
  def index
    "The index"
  end
end

context "try Mongrel" do

  Global.adapter = :mongrel
  start

  specify "simple request" do
    (open('http://localhost:7000/').read).should_equal "The index"
  end
end

context "try Webrick" do

  Global.adapter = :webrick
  start

  specify "simple request" do
    (open('http://localhost:7000/').read).should_equal "The index"
  end
end
